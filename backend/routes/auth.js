const express = require("express");
const router = express.Router();
const { register, login, updateProfile, verifyToken } = require("../controllers/authController");
const { uploadProfilePicture, deleteProfilePicture } = require("../controllers/uploadController");

router.post("/register", register);
router.post("/login", login);
router.put("/profile", verifyToken, updateProfile);
router.post("/profile/picture", verifyToken, uploadProfilePicture);
router.delete("/profile/picture", verifyToken, deleteProfilePicture);

module.exports = router;
