// API_URLという定数を定義 
const API_URL = "/api";  // Nginxのリバースプロキシを経由するための相対パス

// updateMessageBox関数を定義
function updateMessageBox(message, isError = false) {
    // idが"response"のHTML要素を取得
    const responseElement = document.getElementById("response");
    // innerTextをmessageに設定
    responseElement.innerText = message;
    // エラー時は赤色、正常時は暗いグレーで表示
    responseElement.style.color = isError ? "red" : "#333";
}

// testAPI関数を定義
function testAPI() {
    // APIリクエスト開始の表示
    updateMessageBox("APIリクエスト中...", false);

    // fetchでAPIエンドポイントにリクエストを送信
    fetch(`${API_URL}/`)
        // レスポンスをテキストに変換
        .then(response => response.text())
        // 取得したテキストをそのまま表示
        .then(text => updateMessageBox(text))
        // エラー発生時はエラー内容を表示
        .catch(error => updateMessageBox("エラー: " + error, true));
}

// testDB関数を定義
function testDB() {
    // DBリクエスト開始の表示
    updateMessageBox("DBリクエスト中...", false);

    // fetchでDBエンドポイントにリクエストを送信
    fetch(`${API_URL}/dbtest`)
        // レスポンスをテキストに変換
        .then(response => response.text())
        // 取得したテキストをそのまま表示
        .then(text => updateMessageBox(text))
        // エラー発生時はエラー内容を表示
        .catch(error => updateMessageBox("エラー: " + error, true));
}
