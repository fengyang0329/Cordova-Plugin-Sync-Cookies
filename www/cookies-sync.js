function CookiesSync() { }

/**
 * method: executeXHR
 *
 * @param message
 * @param successCallback
 * @param errorCallback
 */
CookiesSync.prototype.executeXHR = function (url, successCallback, errorCallback) {

	if ((url.substr(0,4)=="http")&&(url.indexOf("\/\/")>=0)) {
			 url = url.slice(url.indexOf("\/\/")+2);
		   };
		   var sPos = url.indexOf("\/");
		   var domain = url.substr(0,sPos);
		   var path = url.substr(sPos,(url.length-sPos));
cordova.exec(successCallback, errorCallback, "CookiesSync", "executeXHR", [url, domain, path]);
};

CookiesSync.install = function () {
	if (!window.plugins) {
		window.plugins = {};
	}

	window.plugins.cookie = new CookiesSync();
	return window.plugins.cookie;
};

cordova.addConstructor(CookiesSync.install);
