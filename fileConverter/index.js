const fs = require("fs");
const bmp = require("bmp-js");
const bmpBuffer = fs.readFileSync("a.bmp");
const bmpData = bmp.decode(bmpBuffer);


var constructedFile = "";
possibleColors = [[240,240,240], [242,178,51], [229,127,216], [153,178,242], [222,222,108], [127,204,25], [242,178,204], [76,76,76], [153,153,153], [76,153,178], [178,102,229], [51,102,204], [127,102,76], [87,166,78], [204,76,76], [17,17,17]]
colorRepresentations = "0123456789abcdef"


for (var k=0; k < bmpData.height; k++) {
for (var i=(k*bmpData.width*4); i < ((k+1)*bmpData.width*4); i+=4) {
R = bmpData.data[i+3]
G = bmpData.data[i+2]
B = bmpData.data[i+1]
difference = []
var lowestDifferece = 9999999;
var lowestDiffereceId = 0

for (j=0; j < possibleColors.length; j++) {
rD = Math.abs(R - possibleColors[j][0])
gD = Math.abs(G - possibleColors[j][1])
bD = Math.abs(B - possibleColors[j][2])


difference[j] = rD+gD+bD



if (difference[j] < lowestDifferece) {
  lowestDifferece = difference[j]
  lowestDiffereceId = j
}
}
constructedFile += colorRepresentations[lowestDiffereceId]

}
constructedFile += ","
}
saveNew(constructedFile)

function saveNew(imageString) {
const fs = require('fs');


fs.writeFile('output.nfla', imageString, (err) => {
  if (err) {
    console.error(err);
    return;
  }
  console.log('it worked');
});

}