var a = [].concat.apply([], [].concat.apply([], ["KPBCKDCCCIDGBDCFPCLAKNLM", "0005CD3F6ED9", "9de6f3dc5000", "0"].map((a) => [a.toLowerCase(), a.toUpperCase()]))
.map((a) => [a, a.split('').reverse().join('')]))
a.push(" ")

function testIt(l) {
  l = md5(l)
  if(l == "e2d637007d81ce1ee186bf7e464d743b") console.log("hit")
}
for(var i=0; i<a.length; i++) {
  for(var k=0; k<a.length; k++) {
    testIt(md5(a[i] + a[j] + a[k]))
    testIt(a[i] + md5(a[j]) + a[k])
    testIt(md5(a[i]) + a[j] + a[k])
    testIt(a[i] + a[j] + md5(a[k]))
    testIt(md5(a[i]) + a[j] + md5(a[k]))
    testIt(a[i] + md5(a[j]) + md5(a[k]))
    testIt(a[i] + a[j] + a[k])
  }
  for(var j=0; j<a.length; j++) {
    testIt(md5(a[i] + a[j]))
    testIt(a[i] + md5(a[j]))
    testIt(md5(a[i]) + a[j])
    testIt(a[i] + a[j])
  }
  testIt(a[i])
}
