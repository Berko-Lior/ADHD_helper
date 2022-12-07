
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();

const RTDatabase = admin.database();

exports.scheduledFunctionCrontab = functions.pubsub.schedule("20 18 * * *")
    .timeZone("Israel")
    .onRun(
        async (context) => {
          const dbRef = RTDatabase.ref("/device1/time_for_next_reset");
          const snap = await dbRef.get();
          await RTDatabase.ref("/device1/time_for_next_reset").set(snap+1);
          return snap;
        });
