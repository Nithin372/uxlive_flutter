from flask import Flask, request, jsonify
import google.oauth2.credentials
import google_auth_oauthlib.flow
import googleapiclient.discovery

app = Flask(__name__)

# OAuth 2.0 configuration
CLIENT_SECRETS_FILE = 'client_secrets.json'  # Replace with your client secrets file
SCOPES = ['https://www.googleapis.com/auth/youtube.force-ssl']
API_SERVICE_NAME = 'youtube'
API_VERSION = 'v3'

@app.route('/get_access_token', methods=['POST'])
def get_access_token():
    # Retrieve authorization code from Flutter application
    auth_code = request.json.get('authorization_code')

    # Set up OAuth 2.0 flow
    flow = google_auth_oauthlib.flow.Flow.from_client_secrets_file(
        CLIENT_SECRETS_FILE, scopes=SCOPES)
    flow.redirect_uri = 'http://localhost:5000/authorize'  # Replace with your redirect URI

    # Exchange authorization code for credentials
    flow.fetch_token(authorization_response=auth_code)

    # Extract and return the access token
    credentials = flow.credentials
    access_token = credentials.token
    return jsonify({'access_token': access_token})

@app.route('/authorize')
def authorize():
    return "Authorization successful. You can close this window and return to the app."

if __name__ == '__main__':
    app.run(debug=True)









from flask import Flask, request,jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify(result="Hello, this is a calculator app!")

@app.route('/add')
def add():
    num1 = request.args.get('num1', type=float)
    num2 = request.args.get('num2', type=float)
    result = num1 + num2
    return jsonify(result=result)

@app.route('/subtract')
def subtract():
    num1 = request.args.get('num1', type=float)
    num2 = request.args.get('num2', type=float)
    result = num1 - num2
    return jsonify(result=result)

@app.route('/multiply')
def multiply():
    num1 = request.args.get('num1', type=float)
    num2 = request.args.get('num2', type=float)
    result = num1 * num2
    return jsonify(result=result)

@app.route('/divide')
def divide():
    num1 = request.args.get('num1', type=float)
    num2 = request.args.get('num2', type=float)
    result = num1 / num2
    return jsonify(result=result)

if __name__ == '__main__':
    app.run()

