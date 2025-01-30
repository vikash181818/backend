const express = require("express");
const verifyToken = require("../../middleware/authMiddleware");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const {
  uploadCarouselImage,
  getAllCarouselImages,
  getCarouselImageById,
  updateCarouselImage,
  deleteCarouselImage,
  getCarouselImagesForUsers,
} = require("../../controllers/carouselControllers/carouselController");

const router = express.Router();
const carouselImgDir = path.resolve(__dirname, "../../assets/carousel");
if (!fs.existsSync(carouselImgDir)) {
  console.log("Creating carousel folder:", carouselImgDir);
  fs.mkdirSync(carouselImgDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    console.log("Saving file to directory:", carouselImgDir); // Log the directory
    cb(null, carouselImgDir);
  },
  filename: (req, file, cb) => {
    const fileName = `${Date.now()}-${file.originalname}`;
    console.log("Generated file name:", fileName); // Log the file name
    cb(null, fileName);
  },
});

const upload = multer({ storage });


// Routes for carousel images

// Admin: Upload a carousel image
router.post("/carousel", verifyToken, upload.single("image"), uploadCarouselImage);

// Admin: Get all carousel images
router.get("/carousel", verifyToken, getAllCarouselImages);

// Admin: Get a specific carousel image by ID
router.get("/carousel/:id", verifyToken, getCarouselImageById);

// Admin: Update carousel image metadata or replace image
router.patch("/carousel/:id", verifyToken, upload.single("image"), updateCarouselImage);

// Admin: Delete a carousel image
router.delete("/carousel/:id", verifyToken, deleteCarouselImage);

// User: Get carousel images in order
router.get("/carousel/public", getCarouselImagesForUsers);

module.exports = router;
