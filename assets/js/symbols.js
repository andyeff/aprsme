/**
 * Returns address of symbol in tables or false if not found
 *
 * @param {string} symbol
 * @return {array|boolean} address in tables or false
 * */
function getAPRSSymbolAddress(symbol) {
    console.log(symbol);
    var tableSymbol = symbol.charAt(0);
    var table = tableSymbol === '/' ? 0 : (tableSymbol === '\\' ? 1 : 2);
    var search = symbol.charAt(1);
    var translation = [
        '!"#$%&\'()*+,-./0', '123456789:;<=>?@', 'ABCDEFGHIJKLMNOP', 'QRSTUVWXYZ[\\]^_`', 'abcdefghijklmnop', 'qrstuvwxyz{|}~'
    ];
    for (var row = 0; row < translation.length; row++) {
        var rowData = translation[row];
        for (var col = 0; col < rowData.length; col++) {
            if (rowData[col] === search) {
                console.log([table, row, col]);
                return [table, row, col];
            }
        }
    }

    console.log("%c Invalid Symbol: " + symbol, "background: #000; color: #fff");
    // handle other special symbols here
    return false;
}

/**
 * Returns <i> tag with propper classes for given address, or false if the address is not correctly provided
 *
 * @param {array} address
 * @return {string|boolean} image tag or false on failure
 * */
function getAPRSSymbolImageTagByAddress(address) {
    if (typeof address === 'undefined' || !Array.isArray(address) || address.length !== 3) {
        return false;
    }
    return "<i class='aprs-table" + address[0] + " aprs-address-" + address[1] + "-" + address[2] + "'></i>";
}

/**
 * Either you can get image tag generated by passing symbol only (such as "/["), or you can get the image tag by providing its address
 *
 * @param {string} symbol
 * @return {string|boolean} image tag, if address was found, false otherwise
 * */
function getAPRSSymbolImageTag(symbol) {
    var address = getAPRSSymbolAddress(symbol);
    return getAPRSSymbolImageTagByAddress(address);
}

export default getAPRSSymbolImageTag;
