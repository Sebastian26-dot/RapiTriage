from flask import Flask, request, jsonify
import pickle
import numpy as np

app = Flask(__name__)

# Load your XGBoost model
with open('xgboost_model.pkl', 'rb') as f:
    model = pickle.load(f)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    
    # Prepare features in the same order as your model expects
    features = np.array([
        data['suhu_tubuh'],
        data['detak_jantung'],
        data['tekanan_darah_sistolik'],
        data['tekanan_darah_diastolik'],
        data['laju_pernapasan'],
        data['saturasi_oksigen'],
        # Add any other features your model needs
    ]).reshape(1, -1)
    
    # Make prediction
    prediction = model.predict(features)
    
    # Map numeric prediction to your triage categories
    triage_map = {0: 'Hijau', 1: 'Kuning', 2: 'Merah'}
    triage_priority = triage_map.get(prediction[0], 'Hijau')
    
    return jsonify({'prediction': triage_priority})

if __name__ == '__main__':
    app.run('http://192.168.0.105:5000', port=5000)