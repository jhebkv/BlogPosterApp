#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#MaxThreadsPerHotkey 5
#MaxHotkeysPerInterval 5
; #Warn  ; Enable warnings to assist with detecting common errors.
SetBatchLines -2
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Subject_TT:="e.g. One Punch Man"
Image_TT:="e.g. https://cdn.myanimelist.net/images/anime/12/76049.jpg"
MovieCode_TT:="e.g. MAL:30276 or IMDB:tt6450804"
URL_TT:="e.g. Watch:https://web.server.com/embed/opm or Download:https://web.server.com/opm.mp4"
Name_TT:="e.g. John Doe"
Message_TT:="Post Body / Description..."
PostNote_TT:="Note..."
gui,add,text,w100,Post Title
gui,add,edit,x+m w350 h20 vSubject hwndTitleMsg,%Subject_TT%
gui,add,text,xm w100,Post Image URL
gui,add,edit,x+m w350 h20 c888888 vImage hwndImageMsg,%Image_TT%
gui,add,text,xm w100,Post Body
gui,add,edit,x+m w240 h20 c888888 vMoviecode hwndScrapURL,%MovieCode_TT%
gui,add,button,x+m w100 vGetInfo ggetinfo,Get Info
gui,add,edit,xm w460 h150 c888888 vMessage hwndMsgMsg,%Message_TT%
gui,add,text,xm w100,Post Note
gui,add,edit,x+m w350 h40 c888888 vPostNote hwndMsgNote,%PostNote_TT%
gui,add,text,xm w100,Post Video URL
gui,add,edit,x+m w350 h20 c888888 vURL hwndUrlMsg,%URL_TT%
gui,add,text,xm w100,Poster Name
gui,add,edit,x+m w130 h20 c888888 vName hwndNameMsg,%Name_TT%
gui,add,button,x+m w100 gsubmit disabled,Submit
gui,add,button,x+m w100 gpreview vCheck,Check Preview
gui,show
OnMessage(0x111,"HelpMsg")
OnMessage(0x200, "WM_MOUSEMOVE")
return
getinfo:
gui,submit,nohide
if !HelpCek(MovieCode)
	return
if !gtemplate(MovieCode,Moviecode)
	guicontrol,,Message
return
preview:
gui,submit,nohide
if !submitchk()
	return
guicontrolget,Check,,Check,Text
if (Check="Back")
	goto Check
preview:=appendmsg(Message,Subject,Image,URL,Name,PostNote,"Preview")
fileappend,%preview%,%a_scriptdir%\preview.html
run,%a_scriptdir%\preview.html
guicontrol,,Check,Back
guicontrol,enable,Submit
return
check:
guicontrol,,Check,Check Preview
guicontrol,disable,Submit
return
submit:
gui,submit,nohide
if !submitchk()
	return
gui,hide
tooltip, Loading...
settimer,restart,15000
appendmsg(Message,Subject,Image,URL,Name,PostNote,"Post")
guicontrol,disable,Submit
guicontrol,,Check,Check Preview
settimer,restart,off
msgbox,,Success,Success!`nYour post has been submitted,`nWaiting for editor to review and publish your content.
gui,show
tooltip
return
restart:
tooltip, Error.
msgbox,,Error,Error!`nFailed submit your post. Please try again later.
reload
guiclose:
guiescape:
filedelete,%a_scriptdir%\preview.html
exitapp
WM_MOUSEMOVE()
{
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 500
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 5000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}
HelpMsg(guival,guiid){
	global TitleMsg,ImageMsg,ScrapURL,MsgMsg,UrlMsg,NameMsg,MsgNote
	global Subject_TT,Image_TT,MovieCode_TT,URL_TT,Name_TT,Message_TT,PostNote_TT
	if (guiid=TitleMsg)
		HelpOn(guival,guiid,Subject_TT)
	if (guiid=ImageMsg)
		HelpOn(guival,guiid,Image_TT)
	if (guiid=ScrapURL)
		HelpOn(guival,guiid,MovieCode_TT)
	if (guiid=UrlMsg)
		HelpOn(guival,guiid,URL_TT)
	if (guiid=NameMsg)
		HelpOn(guival,guiid,Name_TT)
	if (guiid=MsgMsg)
		HelpOn(guival,guiid,Message_TT)
	if (guiid=MsgNote)
		HelpOn(guival,guiid,PostNote_TT)
}
HelpOn(guival,guiid,txt,alignr=""){
	If ((guival>>16)=0x100) { ; EN_SETFOCUS = 0x1003
		GuiControlGet,guiid,Name,%guiid%
		GuiControlGet,val,,%guiid%
		val:=HelpCek(val,txt)
		IfEqual,val,%txt%
		{
			GuiControl,,%guiid%
			GuiControl,+c000000,%guiid%
			if alignr
				GuiControl,+Right,%guiid%
		}
	}
	If ((guival>>16)=0x200) { ; EN_KILLFOCUS
		GuiControlGet,guiid,Name,%guiid%
		GuiControlGet,val,,%guiid%
		val:=HelpCek(val,txt)
		IfEqual,val,0
		{
			GuiControl,,%guiid%,%txt%
			GuiControl,+c888888,%guiid%
			if alignr
				GuiControl,+Left,%guiid%
		}
	}
}
HelpCek(val,txt=""){
	global Subject_TT,Image_TT,MovieCode_TT,URL_TT,Name_TT,Message_TT,PostNote_TT
	if !val
		return 0
	if (val="")
		return 0
	if (val="ERROR")
		return 0
	if (val="0")
		return 0
	if !txt
		if ((val=Subject_TT) || (val=Image_TT) || (val=MovieCode_TT) || (val=URL_TT) || (val=Name_TT) || (val=Message_TT) || (val=PostNote_TT) || (val=""))
			return 0
	return val
}
gtemplate(code,scrap=""){
	filedelete,%a_scriptdir%\movinfo.tmp
	if !scrap
		return 0
	stringleft,a,code,4
	if (a="IMDB")
		stringtrimleft,code,code,5
	else if (a="MAL")
		stringtrimleft,code,code,4
	stringleft,a,code,2
	if (a="tt")
		mov:="https://www.imdb.com/title/" code
	else if a is number
		mov:="https://myanimelist.net/anime/" code
	else
		return 0
	src:=mov
	urldownloadtofile,%mov%,%a_scriptdir%\movinfo.tmp
	fileread,b,%a_scriptdir%\movinfo.tmp
	if (a="tt") {
		a:="error_code_404"
		ifinstring,b,%a%
			return 0
		a:="<title>TryIMDbProFree</title>"
		ifinstring,b,%a%
			stringreplace,b,b,%a%,,all
		mz:=ghtmldt(b,"<title>","</title>","-","a,span") ;get release date
		mr:=ghtmldt(b,"title=""See more release dates"" >","</a>","|","a,span") ;get release date
		mx:=ghtmldt(b,"<span itemprop=""ratingValue"">","</span>","|","a,span") ; get rating
		ms:=ghtmldt(b,"<div class=""summary_text"">","</div>","|","a,span") ; get summary
		a:="<h4 class=""inline"">Directors:</h4>"
		ifnotinstring,b,%a%
			stringreplace,a,a,Directors,Director,all
		md:=ghtmldt(b,a,"</div>","|","a,span") ; get director
		a:="<h4 class=""inline"">Writers:</h4>"
		ifnotinstring,b,%a%
			stringreplace,a,a,Writers,Writer,all
		mw:=ghtmldt(b,a,"</div>","|","a,span") ; get writer
		a:="<h4 class=""inline"">Stars:</h4>"
		ifnotinstring,b,%a%
			stringreplace,a,a,Stars,Star,all
		mt:=ghtmldt(b,a,"</div>","|","a,span") ;get stars
		a:="<h4 class=""inline"">Genres:</h4>"
		c:=""
		ifnotinstring,b,%a%
		{
			a:="<div class=""subtext"">"
			c:="|"
		}
		mg:=ghtmldt(b,a,"</div>",c,"a,span") ;get genres
		a:="<h1 class=""long"">"
		ifnotinstring,b,%a%
			stringreplace,a,a,long,,all
		mo:=ghtmldt(b,a,"</h1>","|","a,span") ;get original title
		mi:=ghtmldt(b,"<div class=""poster"">","</div>","|","a,span") ;get img poster strt
		mi:=ghtmldt(mi,"src=""","""","|","a,span") ;get img poster end
		b=
		(LTrim
		<span class="AppList">Original Title</span>: %mo%
		<span class="AppList">Release Date</span>: %mr%
		<span class="AppList">Rating</span>: %mx%
		<span class="AppList">Genres</span>: %mg%
		<span class="AppList">Director(s)</span>: %md%
		<span class="AppList">Writer(s)</span>: %mw%
		<span class="AppList">Star(s)</span>: %mt%
		<span class="AppList">Summary</span>: %ms%
		<div style="display:block;"></div>
		<p style="font-size:12px;text-align:right;"><i>Source: %src%</i></p>
		)
		filedelete,%a_scriptdir%\movinfo.tmp
		return btemplate(b,mz,mi)
	}
	a:="404 Not Found"
	ifinstring,b,%a%
		return 0
	a:="<span class=""dark_text"">Synonyms:</span>"
	ifnotinstring,b,%a%
		stringreplace,a,a,Synonyms,English,all
	ifnotinstring,b,%a%
		stringreplace,a,a,English,Japanese,all
	mo:=ghtmldt(b,a,"</div>","","a,span") ;get original title
	mz:=ghtmldt(b,"<title>","</title>","-","a,span")
	mr:=ghtmldt(b,"<span class=""dark_text"">Aired:</span>","</div>","","a,span") ;get Air date
	me:=ghtmldt(b,"<span class=""dark_text"">Episodes:</span>","</div>","","a,span") ;get episodes
	mt:=ghtmldt(b,"<span class=""dark_text"">Type:</span>","</div>","","a,span") ;get type
	mg:=ghtmldt(b,"<span class=""dark_text"">Genres:</span>","</div>","","a,span") ;get genre
	mx:=ghtmldt(b,"<div class=""fl-l score""","</div>","","a,span",">") ;get score/rating
	mx2:=ghtmldt(b,"<span class=""dark_text"">Rating:</span>","</div>","","a,span") ;get rating
	mp:=ghtmldt(b,"<span class=""dark_text"">Producers:</span>","</div>","","a,span") ;get producers
	ms:=ghtmldt(b,"<span class=""dark_text"">Studios:</span>","</div>","","a,span") ;get studios
	my:=ghtmldt(b,"<span itemprop=""description"">","</div>","Edit","a,span,h2,div") ;get synopsis
	my:=rmtagdt(my,"</span>","</span>")
	mi:=ghtmldt(b,"<div class=""js-scrollfix-bottom"" style=""width: 225px"">","</div>","","a,span,div") ;get imgposter
	mi:=ghtmldt(mi,"src=""","""","|","a,span") ;get img poster end
	b=
	(LTrim
	<span class="AppList">Synonyms</span>: %mo%
	<span class="AppList">Movie Type</span>: %mt%
	<span class="AppList">Episodes</span>: %me%
	<span class="AppList">Aired Date</span>: %mr%
	<span class="AppList">Score/Rating</span>: %mx%, %mx2%
	<span class="AppList">Genres</span>: %mg%
	<span class="AppList">Producer(s)</span>: %mp%
	<span class="AppList">Studio(s)</span>: %ms%
	<span class="AppList">Synopsis</span>: %my%
	<div style="display:block;"></div>
	<p style="font-size:12px;text-align:right;"><i>Source: %src%</i></p>
	)
	filedelete,%a_scriptdir%\movinfo.tmp
	return btemplate(b,mz,mi)
}
ghtmldt(html,srca,srcb,brk="",rmtag="",srcax=""){ ; ghtmldt(htmlsrc,datafrom,datato,"forcebreakat,fba2?","removetag,rmtag2?")
	ifnotinstring,html,%srca%
		return ""
	x:=gtagval(html,srca,srcb)
	stringsplit,brk,brk,`,
	stringsplit,rmtag,rmtag,`,
	loop %brk0%
		x:=brk ? rmgleft(x,brk%A_Index%) : x
	loop %rmtag0%
		x:=rmtag ? rmtagln(x,rmtag%A_Index%) : x
	x:=rmbword(x,1) ;get release date
	loop {
		ifinstring,x,%a_space%%a_space%
			stringreplace,x,x,%a_space%%a_space%,%a_space%,all
		else ifinstring,x,`n
			stringreplace,x,x,`n,%a_space%,all
		else ifinstring,x,&nbsp;
			stringreplace,x,x,`&nbsp`;,%a_space%,all
		else
			break
	}
	if srcax {
		stringgetpos,a,x,%srcax%
		stringlen,b,srcax
		b:=b+a
		stringtrimleft,x,x,%b%
	}
	return x
}
rmtagdt(val,srca,srcb,srcx=""){
	stringgetpos,a,val,%srca%
	stringtrimleft,b,val,%a%
	stringgetpos,a,b,%srcb%
	stringtrimright,b,b,%a%
	stringreplace,val,val,%b%,,all
	return val
}
gtagval(val,w,e){
	stringlen,c,w
	stringgetpos,a,val,%w% ;get summary
	a:=a+c
	stringtrimleft,val,val,%a%
	val:=rmbword(val)
	stringgetpos,a,val,%e%
	stringleft,val,val,%a%
	val:=rmbword(val,1)
	return val
}
rmgleft(val,w){
	ifinstring,val,%w%
	{
		stringgetpos,a,val,%w%
		stringleft,val,val,%a% ;get summary end
	}
	return val
}
rmtagln(val,w){
	loop {
		ifinstring,val,<%w%
		{
			stringlen,c,w
			stringgetpos,a,val,<%w%
			stringtrimleft,a,val,%a%
			stringgetpos,b,a,>
			b:=b+1
			stringleft,a,a,%b%
			stringreplace,val,val,%a%,,all
			stringreplace,val,val,</%w%>,,all
		} else
			return val
	}
}
rmbword(b,r=""){
	loop {
		stringleft,a,b,1
		if (r=1)
			stringright,a,b,1
		if ((a=a_space) or (a="`n") or (a=a_tab) or (a="&") or (a=";")) {
			if (r=1)
				stringtrimright,b,b,1
			else
				stringtrimleft,b,b,1
		}
		else 
			return b
	}
}
btemplate(inf,title,img){
	desc=
	(
	<div style="text-align:justify;width:100`%;">%inf%</div>
	)
	guicontrol,,Subject,%title%
	guicontrol,,Image,%img%
	guicontrol,,Message,%desc%
	return desc
}
submitchk(){
	global Subject,Message,Image,Name
	filedelete,%a_scriptdir%\preview.html
	if !HelpCek(Subject)
		return 0
	if !HelpCek(Message)
		return 0
	if !HelpCek(Name)
		return 0
	if !HelpCek(Image)
		return Image:="https://lh6.googleusercontent.com/hv_nTdoEabWlA_WDQJxPKqEHzlcmmMxxGsSwkickPYX1aU-z-I2knCFDG_8rE4ucqglRFvAplbRkM6OUErsV"
	return 1
}
appendmsg(msg,sbj,img="",url="",nm="",note="",opt=""){
	stringreplace,msg,msg,`n,<br />,all
	stringreplace,note,note,`n,<br />,all
	loop
	{
		ifinstring,msg,<br /><br />
			stringreplace,msg,msg,<br /><br />,<br />,all
		else
			break
	}
	if (opt="preview")
	sbj=
	(
	<div class="AppSubject"><h1>%sbj%</h1>
	<p>%A_Tab% <b>%nm%</b> - %A_Mon% %A_DD%, %A_YYYY%</p>
	</div>
	)
	stringleft,a,url,8
	if (a="download") {
		stringtrimleft,url,url,9
		divurl=
		(LTrim
		<br /><a href="%url%" target="_blank" class="post-btn">Download Now</a><br />
		)
	} else {
		stringleft,a,a,5
		if (a="watch")
			stringtrimleft,url,url,6
		if !HelpCek(url)
			divurl:=""
		else
			divurl=
			(LTrim
			<style>
			.AppAttach {
			padding-top: 56.25`%;
			position: relative;
			margin-bottom: 25px;
			}
			.AppAttach iframe {
			width: 100`%;
			height: 100`%;
			position: absolute;
			top: 0;
			left: 0;
			}
			.AppAttach-Button {
			position: relative;
			top: 20px;
			}
			</style>
			<script>
			function myTheater(y) {
			var x = document.getElementsByClassName("demo");
			if (y == "T") {
			x[0].style.display = "none";
			x[1].style.display = "";
			var x = document.getElementsByClassName("AppAttach")[0];
			x.style.zIndex  = "11";
			x.style.width = "100vw";
			x.style.height = "100vh";
			x.style.top = "0";
			x.style.textAlign = "center";
			x.style.left = "0";
			x.style.background = "rgba(0,0,0,0.75)";
			x.style.position = "fixed";
			var x = x.getElementsByTagName("iframe")[0];
			x.style.width = "60vw";
			x.style.height = "33.75vw";
			x.style.left = "20vw";
			x.style.top = "1`%";
			var x = document.getElementsByClassName("AppAttach-Button")[0];
			x.style.marginTop = "-20vw";
			x.style.left = "20vw";
			x.style.top = "-15px";
			} else {
			x[0].style.display = "";
			x[1].style.display = "none";
			var x = document.getElementsByClassName("AppAttach")[0];
			x.style.zIndex  = "0";
			x.style.width = "100`%";
			x.style.textAlign = "left";
			x.style.height = "0`%";
			x.style.background = "rgba(0,0,0,0.0)";
			x.style.position = "relative";
			var x = x.getElementsByTagName("iframe")[0];
			x.style.width = "100`%";
			x.style.height = "100`%";
			x.style.left = "0";
			x.style.top = "0";
			var x = document.getElementsByClassName("AppAttach-Button")[0];
			x.style.marginTop = "0";
			x.style.left = "0";
			x.style.top = "20px";
			}
			}
			</script>
			<iframe src="%url%"></iframe>
			<div class="AppAttach-Button"><a class="button small visit" href="%url%" target="_blank">View in New Tab</a> <a class="button small demo" href="#" onclick="myTheater('T')">Theater Mode</a> <a class="button small demo" href="#" onclick="myTheater('N')" style="display:none">Normal Mode</a><br /></div>
			)
	}
	if !HelpCek(note)
		note:=""
	msg=
	(LTrim
	<style>
	.AppBody {
	Max-Width:630px;
	}
	.AppImage {
	Max-Width:29`%;
	Margin-Bottom:20px;
	Margin-Left:20px;
	Float:right;
	Position:relative;
	}
	.AppImage img {
	Max-Width:100`%;
	Max-Height:400px;
	}
	.AppMessage {
	Margin:0px;
	Margin-Bottom:20px;
	Padding-Left:1`%;
	Display:inline-block;
	Text-Align:justify;
	}
	.AppMessage p {
	Margin:0px;
	}
	.AppPosterName {
	Text-align:right;
	}
	span.AppList {
	Width:100px;
	Display:inline-block;
	Font-Weight:bold;
	}
	div.AppNote {
	Margin-Top:40px;
	}
	</style>
	<div class="AppBody">
	<div class="AppMessage">
	<div class="AppImage"><img src="%img%" /></div>
	<p>%msg%</p></div>
	<div class="AppAttach">%divurl%</div>
	<div class="AppNote alert-message alert">%note%</div>
	<div class="AppPosterName"><i>Posted by:</i> <b>%nm%</b> via <a href="http://archives.jeffarts.cf/2019/05/blogposterapp-everyone-can-post-to-this.html" target="_blank">Archives.BlogPosterApp</a></div>
	</div>
	)
	if (opt="preview") {
		preview=
		(LTrim
		<style>
		h1 {margin-bottom:0px;} p {margin-top:0px;}
		</style>
		<div style="width:100`%;text-align:center;">
		<div style="width:630px;margin:auto;text-align:justify;">
		<div style="margin-left:7px">%sbj%</div>
		%msg%
		</div></div>
		)
		return preview
	}
	random,rand,0,255
	pmsg 			:= ComObjCreate("CDO.Message")
	pmsg.From 		:= nm """ via BlogPosterApp"" <BlogPoster@JeffArts.cf>"
	pmsg.To 		:= "archives.jeffarts" rand ".cf" rand "@blogger.com" ; Posting using email archives.jeffarts.cf (Mail2Blogger email)
	pmsg.BCC 		:= ""   ; Blind Carbon Copy, Invisable for all, same syntax as CC
	pmsg.CC 		:= ""
	pmsg.Subject 	:= sbj

	;You can use either Text or HTML body like
	;~ pmsg.TextBody 	:= "Message_Body_Example"
	;OR
	pmsg.HtmlBody := msg

	sAttach   		:= "" ; can add multiple attachments, the delimiter is |
	random,rand,0,255
	fields := Object()
	fields.smtpserver   := "smtp.gmail.com" ; specify your SMTP server
	fields.smtpserverport     := 465 ; 25
	fields.smtpusessl      := True ; False
	fields.sendusing     := 2   ; cdoSendUsingPort
	fields.smtpauthenticate     := 1   ; cdoBasic
	fields.sendusername := "archives.jeffarts" rand "@gmail.com" ; Mail App Sender (https://myaccount.google.com/apppasswords)
	fields.sendpassword := "" ; Mail App Passwords
	fields.smtpconnectiontimeout := 60
	schema := "http://schemas.microsoft.com/cdo/configuration/"

	pfld :=   pmsg.Configuration.Fields

	For field,value in fields
		pfld.Item(schema . field) := value
	pfld.Update()

	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
	  pmsg.AddAttachment(A_LoopField)
	pmsg.Send()
}
