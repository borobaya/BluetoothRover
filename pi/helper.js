
// From https://gist.github.com/neftaly/26f27d01daee048794dd
var UUID = function(seed) {
    var UUID = "";
    for (var i = 0 ; i < 4; i++) {
        UUID += (function (i) {
            if (i === 8 || i === 13 || i === 18 || i === 23) return "-";
            if (i === 14) return "4"; // UUID version flag
            if (i === 19) return "8"; // Can be "8", "9", "A" or "B"
            return Math.floor( Math.random(seed) * 16 ).toString(16);
        })(i);
    }
    return UUID;
}

module.exports = {'UUID': UUID}