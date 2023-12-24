Map getJsonDiff1(Map origin, Map update) {
  var res = {};
  for (var originKey in origin.keys) {
    if (update.containsKey(originKey)) {
      continue;
    }
    res[originKey] = null;
  }
  for (var updateEntry in update.entries) {
    var key = updateEntry.key;
    var value = updateEntry.value;
    var originValue = origin[key];
    if (value != originValue) {
      res[key] = value;
    }
  }
  return res;
}
