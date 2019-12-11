value=(value.match(/.*/gm)).toString()
var re=/Name:\s*\S*Raid Level:\s*\S*(?=(,,,))/gmi;
var matches = value.match(re);
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
    var str = matches[i].split('\n');
    for(var x = 0; x < str.length; x++){
       var temp  = str[x].split(':');
myobj.add(temp[0],temp[1]);
    } 
prejson= prejson + "," + (((JSON.stringify(myobj,null,space=0)).replace(/{"obj":{"Name":"\s*/gm,'{"LDNAME":"')).replace(/}$/,""));
}
json=("[" + prejson + "]").replace(/\[,/,"[").replace(/\s{2,}/gm,""
return json