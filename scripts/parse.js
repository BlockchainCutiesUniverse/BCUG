var fs = require('fs');
var util = require('util');

function readFiles(dirname, onFileContent, onError) {
  fs.readdir(dirname, function(err, filenames) {
    if (err) {
      onError(err);
      return;
    }
    filenames.forEach(function(filename) {
      fs.readFile(dirname + filename, 'utf-8', function(err, content) {
        if (err) {
          onError(err);
          return;
        }
        onFileContent(filename, content);
      });
    });
  });
}

function callback(error) {
	if (error)
	{
		console.log(error);
	}
}

readFiles("build/contracts/", async function(filename, str)
{
	console.log(filename);
	var obj = JSON.parse(str);
//	console.log(obj.abi);

//	const t = compiled.contracts[c+'.sol:'+c];
	fs.writeFile("build/" + filename, JSON.stringify(obj.abi, null, 2), callback);
	fs.writeFile("build/" + filename+'-bytecode', obj.bytecode, callback);
//	fs.writeFile("build/" + filename+'-gasEstimates.json', util.inspect(obj.gasEstimates), callback);
//	fs.writeFile("build/" + filename+'-source.js', obj.source, callback);

},
function(error)
{
	console.log(error);
}
);


