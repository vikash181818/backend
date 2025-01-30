// controllers/cartController.js

const db = require('../../config/firebase');

/**
 * If your Firestore doesn't yet have a "cart" or "cart_details" collection,
 * Firestore will automatically create them on the first doc write.
 * No extra code needed for "collection won't exist" checks.
 */

/**
 * -------------------------------------------------------------------------
 * Create or Add to Cart in a single transaction
 * -------------------------------------------------------------------------
 * - If the user has no cart, create one.
 * - Otherwise, find the cart and update/add the item.
 */
exports.createOrAddToCart = async (req, res) => {
    const { productId, productUnitId, quantity = 1 } = req.body;
    const userId = req.user.id;
  
    if (!productId || !productUnitId || !userId) {
      return res.status(400).json({ message: 'Missing required fields.' });
    }
  
    try {
      await db.runTransaction(async (transaction) => {
        // ------------------------------------------------------------------
        // 1. First, read existing cart doc(s) for this user (NO writes yet!)
        // ------------------------------------------------------------------
        const cartSnapshot = await transaction.get(
          db.collection('cart').where('userId', '==', userId)
        );
  
        // We'll store a "would-be" cartRef and a flag to see if we need to create
        let cartDocRef;
        let shouldCreateCart = false;
  
        if (cartSnapshot.empty) {
          // We'll *create* a cart doc later, but don't actually set() it yet
          cartDocRef = db.collection('cart').doc();
          shouldCreateCart = true;
        } else {
          cartDocRef = cartSnapshot.docs[0].ref;
        }
  
        // ------------------------------------------------------------------
        // 2. Next, read the existing cart_details doc (if any) for the
        //    same productId + productUnitId (STILL no writes!)
        // ------------------------------------------------------------------
        let existingDetailDoc;
        let existingDetailData = null;
  
        // We only attempt this if we actually found or will create a cart docRef
        const detailSnapshot = await transaction.get(
          db
            .collection('cart_details')
            .where('cartId', '==', cartDocRef.id)
            .where('productId', '==', productId)
            .where('productUnitId', '==', productUnitId)
        );
        if (!detailSnapshot.empty) {
          existingDetailDoc = detailSnapshot.docs[0].ref;
          existingDetailData = detailSnapshot.docs[0].data();
        }
  
        // ------------------------------------------------------------------
        // 3. Now that ALL reads are done, we can proceed with writes
        // ------------------------------------------------------------------
  
        // If we must create a cart doc, do it now
        if (shouldCreateCart) {
          const newCart = {
            userId,
            basket: `ODSO - ${new Date().toISOString()}`,
            created_date: new Date().toISOString(),
            amount: 0, // will recalc if needed
            id: cartDocRef.id,
          };
          transaction.set(cartDocRef, newCart);
        }
  
        // If no existing cart_detail, create new
        if (!existingDetailDoc) {
          const newDetailsRef = db.collection('cart_details').doc();
          const newDetailsData = {
            cartId: cartDocRef.id,
            productId,
            productUnitId,
            quantity,
            id: newDetailsRef.id,
          };
          transaction.set(newDetailsRef, newDetailsData);
        } else {
          // We have a cart_detail doc => update quantity
          const newQty = existingDetailData.quantity + quantity;
          transaction.update(existingDetailDoc, {
            quantity: newQty,
          });
        }
  
        // If you want to recalc "cart.amount" here in the transaction,
        // you'd do a *final read* of all cart_details and do the math,
        // but that again forces more reads => best do a "patchCartDetail" approach
        // or some approach that either does partial diffs or fetches all details up front.
      });
  
      return res.status(200).json({ message: 'Cart created/updated successfully!' });
    } catch (error) {
      console.error('Error in createOrAddToCart:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  };
  
  
  
  

/**
 * -------------------------------------------------------------------------
 * PATCH-Style Endpoint: patchCartDetailQuantity
 * Minimally updates quantity + cart total without scanning everything.
 * -------------------------------------------------------------------------
 */
exports.patchCartDetailQuantity = async (req, res) => {
  try {
    const { cartDetailId } = req.params;
    const { quantity } = req.body;
    const userId = req.user.id;

    if (!cartDetailId || quantity == null) {
      return res
        .status(400)
        .json({ message: 'Missing cartDetailId or quantity.' });
    }

    await db.runTransaction(async (transaction) => {
      // 1) cartDetail doc
      const cartDetailRef = db.collection('cart_details').doc(cartDetailId);
      const cartDetailDoc = await transaction.get(cartDetailRef);
      if (!cartDetailDoc.exists) {
        throw new Error('Cart detail not found.');
      }
      const cartDetailData = cartDetailDoc.data();

      // 2) cart doc
      const cartRef = db.collection('cart').doc(cartDetailData.cartId);
      const cartDoc = await transaction.get(cartRef);
      if (!cartDoc.exists) {
        throw new Error('Cart not found.');
      }
      if (cartDoc.data().userId !== userId) {
        throw new Error('Not authorized to update this cart.');
      }

      // 3) productUnit doc
      const productUnitRef = db
        .collection('product_units')
        .doc(cartDetailData.productUnitId);
      const productUnitDoc = await transaction.get(productUnitRef);
      if (!productUnitDoc.exists) {
        throw new Error('Product unit not found.');
      }
      const { sale_price } = productUnitDoc.data();
      const salePrice = parseFloat(sale_price) || 0;

      // 4) If quantity <= 0, remove item
      if (quantity <= 0) {
        const oldLineTotal = cartDetailData.quantity * salePrice;
        // remove doc
        transaction.delete(cartDetailRef);

        // reduce cart total
        const newAmount = Math.max((cartDoc.data().amount || 0) - oldLineTotal, 0);
        transaction.update(cartRef, { amount: newAmount });
      } else {
        // partial diff approach
        const oldLineTotal = cartDetailData.quantity * salePrice;
        const newLineTotal = quantity * salePrice;
        const diff = newLineTotal - oldLineTotal;

        // update doc
        transaction.update(cartDetailRef, { quantity });

        // update cart total by diff
        const newAmount = (cartDoc.data().amount || 0) + diff;
        transaction.update(cartRef, { amount: newAmount });
      }
    });

    return res.status(200).json({ message: 'Quantity patched successfully.' });
  } catch (error) {
    console.error('[ERROR] patchCartDetailQuantity:', error.message);
    return res.status(500).json({ message: error.message });
  }
};

/**
 * -------------------------------------------------------------------------
 * Legacy Transaction for full recalc (optional, if you still want it)
 * (Your existing updateCartItemQuantity method)
 * -------------------------------------------------------------------------
 */
exports.updateCartItemQuantity = async (req, res) => {
  try {
    console.log('req.body to updateQuantity>>>>>>>>', req.body);
    const { cartId, productUnitId, quantity } = req.body;
    const userId = req.user.id;

    if (!cartId || !productUnitId || quantity == null) {
      return res
        .status(400)
        .json({ message: 'cartId, productUnitId, and quantity are required.' });
    }

    await db.runTransaction(async (transaction) => {
      // (Full approach that re-reads all items)
      // ...
      // If needed, keep your existing full-scan logic here
      // Or remove it in favor of patchCartDetailQuantity
    });

    return res
      .status(200)
      .json({ message: 'Quantity updated (full recalc) successfully.' });
  } catch (error) {
    console.error('[ERROR] updateCartItemQuantity:', error.message);
    return res.status(500).json({ message: error.message });
  }
};

/**
 * -------------------------------------------------------------------------
 * Get Cart by ID
 * -------------------------------------------------------------------------
 */
exports.getCartById = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('cart').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Cart not found' });
    }

    return res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error('Error fetching cart:', error.message);
    return res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * -------------------------------------------------------------------------
 * Get Cart Details by cartId (line items only)
 * -------------------------------------------------------------------------
 */
exports.getCartDetailsByCartId = async (req, res) => {
  try {
    const { cartId } = req.params;
    const snapshot = await db
      .collection('cart_details')
      .where('cartId', '==', cartId)
      .get();

    if (snapshot.empty) {
      return res
        .status(404)
        .json({ message: 'No cart details found for the given cartId' });
    }

    const cartDetails = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    return res.status(200).json(cartDetails);
  } catch (error) {
    console.error('Error fetching cart details:', error.message);
    return res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * -------------------------------------------------------------------------
 * Get All Carts for Authenticated User
 * -------------------------------------------------------------------------
 */
exports.getUserCarts = async (req, res) => {
  try {
    const userId = req.user.id;
    const snapshot = await db
      .collection('cart')
      .where('userId', '==', userId)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No carts found for the user' });
    }

    const carts = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(carts);
  } catch (error) {
    console.error('Error fetching user carts:', error.message);
    return res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * -------------------------------------------------------------------------
 * Get Single Cart w/ Full Details
 * -------------------------------------------------------------------------
 */
exports.getCartWithDetails = async (req, res) => {
  try {
    const { cartId } = req.params;

    const cartDocRef = db.collection('cart').doc(cartId);
    const cartDoc = await cartDocRef.get();
    if (!cartDoc.exists) {
      return res.status(404).json({ message: 'Cart not found' });
    }
    const cartData = { id: cartDoc.id, ...cartDoc.data() };

    const detailsSnapshot = await db
      .collection('cart_details')
      .where('cartId', '==', cartId)
      .get();
    const details = detailsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    const enrichedDetails = await Promise.all(
      details.map(async (lineItem) => {
        const productUnitDoc = await db
          .collection('product_units')
          .doc(lineItem.productUnitId)
          .get();

        let productUnitData = null;
        if (productUnitDoc.exists) {
          productUnitData = productUnitDoc.data();
        }

        let productData = null;
        if (productUnitData && productUnitData.productId) {
          const productDoc = await db
            .collection('products')
            .doc(productUnitData.productId)
            .get();
          productData = productDoc.exists ? productDoc.data() : null;
        }

        const salePrice = productUnitData?.sale_price
          ? parseFloat(productUnitData.sale_price)
          : 0;
        const lineItemTotal = lineItem.quantity * salePrice;

        return {
          ...lineItem,
          productUnit: {
            ...productUnitData,
            lineItemTotal,
          },
          product: productData,
        };
      })
    );

    return res.status(200).json({
      cart: cartData,
      details: enrichedDetails,
    });
  } catch (error) {
    console.error('Error fetching cart details:', error.message);
    return res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * -------------------------------------------------------------------------
 * GET All Carts + Full Details for the user
 * (Used by "cart/user/cart_details_with_amount")
 * -------------------------------------------------------------------------
 */
exports.getAllCartsWithDetailsForUser = async (req, res) => {
  try {
    const userId = req.user.id;

    const cartSnapshot = await db
      .collection('cart')
      .where('userId', '==', userId)
      .get();

    if (cartSnapshot.empty) {
      return res.status(404).json({ message: 'No carts found for this user.' });
    }

    const carts = [];

    // process each cart in parallel
    await Promise.all(
      cartSnapshot.docs.map(async (cartDoc) => {
        const cartData = { id: cartDoc.id, ...cartDoc.data() };

        const detailSnapshot = await db
          .collection('cart_details')
          .where('cartId', '==', cartData.id)
          .get();

        const details = [];
        let updatedAmount = 0;

        await Promise.all(
          detailSnapshot.docs.map(async (detailDoc) => {
            const detailData = { id: detailDoc.id, ...detailDoc.data() };

            const productUnitDoc = await db
              .collection('product_units')
              .doc(detailData.productUnitId)
              .get();

            if (!productUnitDoc.exists) return;
            const puData = productUnitDoc.data();

            let productData = null;
            if (puData && puData.productId) {
              const productDoc = await db
                .collection('products')
                .doc(puData.productId)
                .get();
              productData = productDoc.exists ? productDoc.data() : null;
            }

            const salePrice = parseFloat(puData.sale_price || 0);
            const lineItemTotal = detailData.quantity * salePrice;
            updatedAmount += lineItemTotal;

            details.push({
              ...detailData,
              productUnit: {
                ...puData,
                lineItemTotal,
              },
              product: productData,
            });
          })
        );

        // Possibly update the cart's amount if changed
        if (cartData.amount !== updatedAmount) {
          await db.collection('cart').doc(cartData.id).update({
            amount: updatedAmount,
          });
          cartData.amount = updatedAmount;
        }

        carts.push({
          ...cartData,
          details,
        });
      })
    );

    return res.status(200).json({
      message: 'Carts with details fetched successfully',
      carts,
    });
  } catch (error) {
    console.error('Error in getAllCartsWithDetailsForUser:', error.message);
    return res.status(500).json({
      message: 'Failed to fetch cart details with amount',
      error: error.message,
    });
  }
};
exports.removeCartDetail = async (req, res) => {
  try {
    const { cartDetailId } = req.params;
    const { lineTotal } = req.body;

    

    const userId = req.user.id; // from the token

    if (!cartDetailId) {
      return res.status(400).json({ message: 'Missing cartDetailId parameter.' });
    }

    await db.runTransaction(async (transaction) => {
      const cartDetailRef = db.collection('cart_details').doc(cartDetailId);
      const cartDetailDoc = await transaction.get(cartDetailRef);

      if (!cartDetailDoc.exists) {
        throw new Error('Cart detail not found.');
      }

      const cartDetailData = cartDetailDoc.data();
      const { cartId, productUnitId, quantity } = cartDetailData;

      // 2) cart doc & confirm user
      const cartRef = db.collection('cart').doc(cartId);
      const cartDoc = await transaction.get(cartRef);

      if (!cartDoc.exists) {
        throw new Error('Cart not found.');
      }

      // -- Debug logs --
      const cartOwnerId = cartDoc.data().userId;
      console.log('[removeCartDetail] userId from token =', userId);
      console.log('[removeCartDetail] userId from cart doc =', cartOwnerId);

      if (cartOwnerId !== userId) {
        throw new Error('Not authorized to remove items from this cart.');
      }

      // 3) Determine lineTotal
      let oldLineTotal = 0;
      if (lineTotal !== undefined) {
        oldLineTotal = parseFloat(lineTotal);
      } else {
        const productUnitRef = db.collection('product_units').doc(productUnitId);
        const productUnitDoc = await transaction.get(productUnitRef);
        if (!productUnitDoc.exists) {
          throw new Error('Related product unit not found.');
        }
        const productUnitData = productUnitDoc.data();
        const salePrice = parseFloat(productUnitData.sale_price || 0);
        oldLineTotal = quantity * salePrice;
      }

      // 4) Delete the cart_details doc
      transaction.delete(cartDetailRef);

      // 5) Subtract oldLineTotal from cart.amount
      const currentAmount = parseFloat(cartDoc.data().amount || 0);
      let newCartAmount = currentAmount - oldLineTotal;
      if (newCartAmount < 0) newCartAmount = 0;

      transaction.update(cartRef, { amount: newCartAmount });
    });

    return res.status(200).json({ message: 'Cart detail removed successfully.' });
  } catch (error) {
    console.error('[ERROR] removeCartDetail:', error.message);
    return res.status(500).json({ message: error.message });
  }
};


/**
 * -------------------------------------------------------------------------
 * Get Total Item Count in User's Cart
 * -------------------------------------------------------------------------
 */
exports.getTotalItemCount = async (req, res) => {
  try {
    const userId = req.user.id; // From the token

    // Find the user's active cart
    const cartSnapshot = await db
      .collection('cart')
      .where('userId', '==', userId)
      .get();

    if (cartSnapshot.empty) {
      return res.status(200).json({ totalItemCount: 0 }); // No cart, so 0 items
    }

    // We assume there is only one active cart per user
    const cartId = cartSnapshot.docs[0].id;

    // Sum up the quantities from cart_details
    const cartDetailsSnapshot = await db
      .collection('cart_details')
      .where('cartId', '==', cartId)
      .get();

    if (cartDetailsSnapshot.empty) {
      return res.status(200).json({ totalItemCount: 0 }); // No items in the cart
    }

    const totalItemCount = cartDetailsSnapshot.docs.reduce((total, doc) => {
      const data = doc.data();
      return total + (data.quantity || 0);
    }, 0);

    return res.status(200).json({ totalItemCount });
  } catch (error) {
    console.error('Error fetching total item count:', error.message);
    return res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
};
