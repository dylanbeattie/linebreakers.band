# Specify the path to ExifTool executable (adjust path as necessary)
$exifToolPath = "C:\Windows\cygwin64\bin\exiftool.exe"

# Specify the path to the image file whose modified time you want to change
$imageFiles = Get-ChildItem -Filter *.jpg

foreach ($imageFile in $imageFiles) {
	# Get the EXIF creation time using ExifTool
	$exifData = & $exifToolPath  -FileName -T -createdate -DateTimeOriginal $imageFile
Write-Host $exifData
	# # Check if EXIF data was retrieved
	# if ($exifData) {
	# 	# Convert the EXIF date/time to a valid DateTime object
	# 	$creationDate = [datetime]::ParseExact($exifData, "yyyy:MM:dd HH:mm:ss", $null)
	# 	# Set the file's LastWriteTime (modified time) to the EXIF creation date
	# 	# (Get-Item $imageFilePath).LastWriteTime = $creationDate
	# 	Write-Host "Modified time updated to EXIF creation time: $creationDate"
	# }

	# else {
	# 	Write-Host "Failed to retrieve EXIF creation time."
	# }
}
