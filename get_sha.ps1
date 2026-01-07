$javaPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
$out = & $javaPath -list -v -keystore "$HOME\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
$sha1 = ($out | Select-String "SHA1:").ToString().Trim()
$sha256 = ($out | Select-String "SHA256:").ToString().Trim()
"SHA1=$sha1`nSHA256=$sha256" | Out-File -FilePath "d:\FlutterProjects\BlindShake\sha_output.txt" -Encoding utf8
