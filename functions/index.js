const functions = require('firebase-functions');
const cors = require('cors')({origin: true});

exports.getFortune = functions.https.onRequest((request, response) => {
  return cors(request, response, async () => {
    // 기존 함수 로직...
    try {
      // 요청 처리
      response.status(200).json({
        // 응답 데이터...
      });
    } catch (error) {
      response.status(500).json({ error: error.message });
    }
  });
}); 