const express = require("express");
const router = express.Router();
const { verifyToken } = require("../controllers/authController");
const {
  getProfiles,
  likeProfile,
  passProfile,
  getMatches,
  unmatch,
} = require("../controllers/matchingController");

router.get("/profiles", verifyToken, getProfiles);
router.post("/like", verifyToken, likeProfile);
router.post("/pass", verifyToken, passProfile);
router.get("/matches", verifyToken, getMatches);
router.delete("/matches/:matchId", verifyToken, unmatch);

module.exports = router;
