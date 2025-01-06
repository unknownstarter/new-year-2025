const functions = require('firebase-functions');
const cors = require('cors')({origin: true});
const fetch = require('node-fetch');

exports.getFortune = functions.https.onRequest((request, response) => {
  return cors(request, response, async () => {
    response.set('Access-Control-Allow-Origin', '*');
    response.set('Access-Control-Allow-Methods', 'GET, POST');
    response.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    if (request.method === 'OPTIONS') {
      response.status(204).send('');
      return;
    }

    try {
      const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
        },
        body: JSON.stringify(request.body)
      });
      
      const data = await openaiResponse.json();
      response.status(200).json(data);
    } catch (error) {
      console.error('Error:', error);
      response.status(500).json({ error: error.message });
    }
  });
}); 