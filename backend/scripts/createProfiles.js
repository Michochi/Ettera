// Script to create Profile documents for existing users
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Profile = require('../models/Profile');

async function createProfilesForExistingUsers() {
  try {
    // Connect to database
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    // Get all users
    const users = await User.find({});
    console.log(`Found ${users.length} users`);

    let created = 0;
    let skipped = 0;

    for (const user of users) {
      // Check if profile already exists
      const existingProfile = await Profile.findOne({ userId: user._id });
      
      if (!existingProfile) {
        // Create profile
        await Profile.create({
          userId: user._id,
          age: user.age || 18,
          location: user.location || null,
          interests: user.interests || [],
          likedProfiles: [],
          passedProfiles: [],
          matches: [],
        });
        console.log(`Created profile for user: ${user.name} (${user.email})`);
        created++;
      } else {
        console.log(`Profile already exists for: ${user.name} (${user.email})`);
        skipped++;
      }
    }

    console.log('\n=== Summary ===');
    console.log(`Total users: ${users.length}`);
    console.log(`Profiles created: ${created}`);
    console.log(`Profiles skipped (already exist): ${skipped}`);

    await mongoose.connection.close();
    console.log('\nDatabase connection closed');
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

createProfilesForExistingUsers();
