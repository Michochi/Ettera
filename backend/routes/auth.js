const express = require("express");
const router = express.Router();
const { register, login, updateProfile, verifyToken } = require("../controllers/authController");

router.post("/register", register);
router.post("/login", login);
router.put("/profile", verifyToken, updateProfile);

module.exports = router;
