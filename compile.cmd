call e compile
call node scripts/parse
mkdir processed
call node scripts/preprocessor.js contracts/
