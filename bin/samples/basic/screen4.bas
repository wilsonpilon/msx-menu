clear500,&hafff:color15,0,0:screen1,2:definta-z
ad=&hb000:defusr=&hb000:defusr1=&hb003
*macloop:reada$:ifa$="end"then*macend
fori=0to63:pokead,val("&h"+mid$(a$,i*2+1,2)):ad=ad+1:next:goto*macloop
data C30FB02100180100033E00CD5600C923235E3456D52100001196B0010008CD5900E17DCD5F002196B0110000010008CD5C002196B0110008010008CD5C002196
data B0110010010008CD5C002100200100183EF0CD56003EC3320DFE2162B0220EFE18A1F1CD1C521600D523CD1C521600EB292929292901001809C109E5EB23CDA4
data 5EE5EB7E235E2356C1E1C5471ACD4D00231310F8E1C9,end
*macend:a=usr(4)

ch=asc("a")
*chloop
sp=0:reada$:s$="":fori=0to7:a=val("&h"+mid$(a$,i*2+1,2)):vpokech*8+i,a:vpoke&h800+ch*8+i,a:vpoke&h1000+ch*8+i,a:next
sp=0:reada$:s$="":fori=0to7:a=val("&h"+mid$(a$,i*2+1,2)):vpoke&h2000+ch*8+i,a:vpoke&h2800+ch*8+i,a:vpoke&h3000+ch*8+i,a:next

*loop
A$="TESTTEST"+chr$(65+rand(100)):CMD12,1,A$
x=rand(32):y=rand(24):vpoke6144+x+y*32,ch+rand(5)
goto*loop

dataFFDFDFDFFFFBFBFB
data4494846444948464
