MODDIR=${0%/*}
echo "这个简单的脚本用于注释/取消注释每次进入rurima环境时候的提示信息。"
echo "This simple script is used to comment out/uncomment the prompt message each time you enter the rurima environment."

f="$MODDIR/.zshrc"
sed -i '1{s/^#//;t;s/^/#/}' "$f"
echo "Current line 1 of .zshrc:"
sed -n '1p' "$f"
