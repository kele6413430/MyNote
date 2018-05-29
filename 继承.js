function SuperType() {
    this.property = true;
}
SuperType.prototype.getSuperValue = function () {
    return this.property;
};
function SubType() {
    this.subProperty = false;
}
SubType.prototype = new SuperType();
SubType.prototype.getSubValue = function () {
    return this.subProperty;
};
SubType.prototype.getSuperValue = function () {
    return this.subProperty;
};
var instance = new SubType();
console.log(instance.getSuperValue());
console.log(instance instanceof Object);
console.log(instance instanceof SuperType);
console.log(instance instanceof SubType);
console.log(Object.prototype.isPrototypeOf(instance));
console.log(SuperType.prototype.isPrototypeOf(instance));
console.log(SubType.prototype.isPrototypeOf(instance));
console.log(instance.getSuperValue());

SubType.prototype = {
    getSubValue:function () {
        return this.subProperty;
    },
    getSuperValue:function () {
        return this.property;
    }
};

function SuperType() {
    this.colors = ["red","blue","green"];
}
function SubType() {}
SubType.prototype = new SuperType();
var instance = new SubType();
instance.colors.push("black");
console.log(instance.colors);
var instance2 = new SubType();
console.log(instance2.colors);
