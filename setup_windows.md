## 1. GitHub for Windows

`http://windows.github.com/` 下载地址见右上角

下载安装登陆后鼠标移到WalletShark上点右边的`clone`

## 2. MySQL

`http://dev.mysql.com/downloads/mysql/` (不确定最新版可用性.. 5.1确定可用)

安装好后在命令行里启动`MySQL Command Line Client`然后执行

```sql
CREATE DATABASE `wallet_shark_development` DEFAULT CHARACTER SET `utf8`;
CREATE USER 'walletshark'@'localhost' IDENTIFIED BY 'walletshark';
GRANT ALL PRIVILEGES ON wallet_shark_development.* TO 'walletshark'@'localhost';
```

## 3. Ruby

`http://rubyinstaller.org/downloads/`

- 下载`Ruby 1.9.3-p392`和`DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe`
- 安装注意都别安装到有空格的目录下面比如`Program Files`
- 先安装`Ruby`, 装好之后从开始菜单运行`Start Command Prompt with Ruby`
- `DevKit`那个运行之后提示你解压到什么地方, 同样别有空格
- 在刚打开的命令行里面`cd`到`DevKit`解压的地方
- 依次执行`ruby dk.rb init`然后`ruby dk.rb install`
- 下载`http://share.aquarhead.me/libmysql.dll`
- 拷贝`libmysql.dll`到`Ruby`安装目录的`bin`子目录下面

## 4. WalletShark

还是用上一步打开的ruby shell, cd到项目目录(如果没改GitHub for Windows默认设置的话是在`C:\Users\你的用户名\Documents\Github\WalletShark`) 然后依次执行

- `gem install bundler`
- `bundle install`
- `padrino rake dm:migrate`
- `padrino start`

如果都没报错那么现在打开浏览器(别用IE或IE内核的比如搜狗/360什么的, 最好Chrome要不就Firefox)访问`127.0.0.1:3000` 如果出来界面了就证明全都好使了

## 5. Sublime Text 2

`http://www.sublimetext.com/2` 推荐此编辑器, 可一直免费试用, 不影响功能

安装好后打开然后按`ctrl+~` 在弹出的命令行里粘贴下面这段代码

```
import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),'wb').write(urllib2.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print('Please restart Sublime Text to finish installation')
```

回车等执行完之后重启

重启之后按`ctrl+shift+p`打开命令盘输入`install`然后选`Package Control: Install Package`那个, 等一会儿会载入可安装的插件, 推荐安装这些`haml`, `BracketHighlighter`, `Auto Encoding for Ruby`和`SideBarEnhancements`

最后选`File` > `Open Folder...`打开项目文件夹就可以了
