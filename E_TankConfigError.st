{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_TankConfigError :
(
    eNoError := 0,
    eLowThresholdOutOfRange := 1,
    eHighThresholdOutOfRange := 2,
    eInvalidThresholdOrder := 3,
    eInvalidTankDepth := 4,
    eInsufficientSensorRange := 5,
	eInvalidRawRange := 6,
	eInvalidSensorRange := 7
);
END_TYPE
