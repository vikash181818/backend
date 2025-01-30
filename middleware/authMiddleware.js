const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
    const authHeader = req.headers.authorization;
  
    console.log("Authorization Header:", authHeader); // Debug header value
  
    if (!authHeader) {
      return res.status(403).json({ message: "Authorization token is required" });
    }
  
    const token = authHeader.split(" ")[1]; // Extract the token from "Bearer <token>"

    console.log("token>>>>>>>>>>>>>>>>>>>>>>>>>>", token); // Debug header value
  
    try {
      console.log("Extracted Token:", token); // Debug extracted token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded; // Attach decoded user info to the request
      next(); // Continue to the next middleware or route
    } catch (error) {
      return res.status(401).json({ message: "Invalid or expired token" });
    }
  };
  

module.exports = verifyToken;
