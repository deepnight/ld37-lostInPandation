@echo off
adt -certificate -validityPeriod 25 -cn SelfSigned 2048-RSA certificate.p12 d
pause