// fix_order_totals.js  —  run with: node fix_order_totals.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // download from Firebase Console

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function fix() {
  const snap = await db.collection('orders').get();
  const batch = db.batch();
  let fixed = 0;

  snap.forEach(doc => {
    const data = doc.data();
    const updates = {};

    for (const field of ['total', 'subtotal', 'deliveryFee']) {
      if (typeof data[field] === 'string') {
        updates[field] = parseFloat(data[field]) || 0.0;
        fixed++;
      }
    }

    if (Object.keys(updates).length > 0) {
      batch.update(doc.ref, updates);
    }
  });

  await batch.commit();
  console.log(`Fixed ${fixed} field(s) across ${snap.size} documents.`);
}

fix().catch(console.error);