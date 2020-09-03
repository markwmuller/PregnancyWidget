clear;
echo "compiling";
monkeyc -d vivoactive4s -f monkey.jungle -o bin/w.prg -y ~/Desktop/developer_key.der;
echo "Killing simulator"
killall simulator; 
echo "running simulator";
/home/mark/Documents/connectiq-sdk-lin-3.1.9-2020-06-24-1cc9d3a70/bin/simulator & 
echo "running app";
monkeydo bin/w.prg vivoactive4s

