export API_KEY=$1
export BUCKET_NAME=$(gcloud config get-value project)

bash create_bucket.sh
bash upload_image.sh donuts.png

cat << EOF > request.json
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$BUCKET_NAME/donuts.png"
          }
        },
        "features": [
          {
            "type": "LABEL_DETECTION",
            "maxResults": 10
          }
        ]
      }
  ]
}
EOF

echo "Label detection start.."

# showing list of labels (words) of what's in your image
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

echo "Label detection end"

echo "Web detection start.."
# change type from LABEL_DETECTION to WEB_DETECTION
sed -i 's/LABEL_DETECTION /WEB_DETECTION/' request.json

# send it to the Vision API
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

echo 'Web detection end'

echo "starting Face Detection.."
bash upload_image.sh selfie.png

# overwrite request.json
cat << EOF > request.json {
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$BUCKET_NAME/selfie.png"
          }
        },
        "features": [
          {
            "type": "FACE_DETECTION"
          },
          {
            "type": "LANDMARK_DETECTION"
          }
        ]
      }
  ]
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

echo "Face Detection end"

echo "starting landmark annotation"
bash upload_image.sh city.png
# overwite request.json
cat << EOF > request.json
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$BUCKET_NAME/city.png"
          }
        },
        "features": [
          {
            "type": "LANDMARK_DETECTION",
            "maxResults": 10,
          }
        ]
      }
  ]
}
EOF

# calling vision API
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

echo "Landmark annotation end"
echo "FINISH!!"