{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_TankState :
(
	eInitializing 	:= 0, 	// Validate configuration
	eReady 			:= 10, 	// System is healthy and waiting
	eRunning		:= 20,	// Pump is operating
	eFault			:= 50	// A fault has occurred
);
END_TYPE
