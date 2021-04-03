// Fake MC68000 for js prototyping

function ToHexStr(val, sz) {
	var len = 8;	// default long
	var s = '00000000' + val.toString(16);
	switch (sz) {
		case "b":
			len = 2;
			break;
		case "w":
			len = 4;
			break;
	}
	return "0x" + s.substring(s.length-len, s.length);
}

function ToBinStr(val, sz) {
	var len = 32;	// default long
	var s = '00000000000000000000000000000000' + val.toString(2);
	switch (sz) {
		case "b":
			len = 8;
			break;
		case "w":
			len = 16;
			break;
	}
	return "0%" + s.substring(s.length-len, s.length);
}

// register constructor
function Register(name, regType) {
	this.Name = name;
	this.Value = 0;
	this.RegType = regType;
	this.Dump = function (name) {
		console.log(this.Name, ToHexStr(this.Value), ToBinStr(this.Value), this.Value);
	}
}

// Data registers
var D0 = new Register("D0","dta");
var D1 = new Register("D1","dta");
var D2 = new Register("D2","dta");
var D3 = new Register("D3","dta");
var D4 = new Register("D4","dta");
var D5 = new Register("D5","dta");
var D6 = new Register("D6","dta");
var D7 = new Register("D7","dta");

// Address registers 
var A0 = new Register("A0","adr");
var A1 = new Register("A1","adr");
var A2 = new Register("A2","adr");
var A3 = new Register("A3","adr");
var A4 = new Register("A4","adr");
var A5 = new Register("A5","adr");
var A6 = new Register("A6","adr");
var A7 = new Register("A7","adr");

// Status register
var SR = new Register("SR","sr");
var SR_CARRY    = parseInt('0000000000000001',2);
var SR_OVERFLOW = parseInt('0000000000000010',2);
var SR_ZERO     = parseInt('0000000000000100',2);
var SR_NEGATIVE = parseInt('0000000000001000',2);
var SR_EXTEND   = parseInt('0000000000010000',2);

function DumpRegisters() {
	console.log("Data registers");
	D0.Dump();
	D1.Dump();
	D2.Dump();
	D3.Dump();
	D4.Dump();
	D5.Dump();
	D6.Dump();
	D7.Dump();
	console.log("Address registers");
	A0.Dump();
	A1.Dump();
	A2.Dump();
	A3.Dump();
	A4.Dump();
	A5.Dump();
	A6.Dump();
	A7.Dump();
}

DumpRegisters();