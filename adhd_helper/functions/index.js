
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();

const RTDatabase = admin.database();

exports.scheduledFunctionCrontab = functions.pubsub.schedule("59 23 * * *")
    .timeZone("Israel")
    .onRun(
        async (context) => {
          updateDatabase("device1");
        });
/**
 *
 * @param {String} deviceId
 * @return {number}
 */
async function updateDatabase(deviceId) {
  const dbRef = RTDatabase.ref("/" + deviceId);
  const deviceJson = (await dbRef.get()).val();

  const timeForNextResrt = deviceJson["time_for_next_reset"];
  const timeForTask = deviceJson["time_for_task"];
  const prevProgress = deviceJson["prev_progress"];
  const progress = deviceJson["progress"];

  const timeForNextResrtRef = dbRef.child("/time_for_next_reset");
  const prevProgressRef = dbRef.child("/prev_progress");
  const progressRef = dbRef.child("/progress");
  const timestempsRef = dbRef.child("/timestemps");

  const currDayProgress = progress - prevProgress;
  const currTime = admin.firestore.Timestamp.now().toDate();
  timestempsRef.child("/"+ currTime).set(currDayProgress);

  if (timeForNextResrt == 1) {
    await progressRef.set(0);
    await prevProgressRef.set(0);
    await timeForNextResrtRef.set(timeForTask);
  } else {
    await prevProgressRef.set(progress);
    await timeForNextResrtRef.set(timeForNextResrt - 1);
  }

  return timeForNextResrt;
}
