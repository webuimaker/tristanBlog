image_dir='/home/tlee/Documents/fascist_forge/images'
output_dir='/home/tlee/Documents/fascist_forge/images_jpg'
mkdir -p $output_dir

for f in $image_dir/*
do
  # echo $f
  filename=$(basename -- "$f")
  filename="${filename%.*}"
  echo $filename
  convert $f -background white -flatten "$output_dir"/"$filename"".jpg"
done