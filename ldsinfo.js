value=(value.match(/.*/gm)).toString()
var matches = value.match(/Name:\s*\S*Raid Level:\s*\d{1,}\S*Size:\s*\S*\s\S*StripeSize:\s*\S*Num Disks:\s*\d{1,2}\S*State:\s*\w*/gmi);
var prejson = '';
function obj(){
    obj=new Object();
    this.add=function(key,value){
        obj[""+key+""]=value;
    }
    this.obj=obj
}
var myobj={};
myobj = new obj();
for(var i = 0; i < matches.length; i++)
{
    var str = matches[i].split(',,,');
    for(var x = 0; x < str.length; x++){
       var temp  = str[x].split(':');
myobj.add(temp[0],temp[1]);
    } 
prejson= prejson + "," + ((JSON.stringify(myobj,null,space=0)).replace(/"obj":{"Name":"\s*/gm,'"')).replace(/,"Raid/,':{"Raid');
}
json=("[" + prejson + "]").replace(/\[,/,"[").replace(/\s{2,}/gm,"")
return json