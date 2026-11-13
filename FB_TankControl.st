FUNCTION_BLOCK FB_Tank
VAR_INPUT
	xStart			: BOOL;
	xStop			: BOOL;
	xReset			: BOOL;
	// Parameters
	iTankDepthCm	: INT := 10000;
	
	// Radar sensor params
	iLevelRaw		: REAL;
	
	iMaxRaw			: INT := 27648;
	iMinRaw			: INT := 0; 
	iMaxSensorCm	: INT := 1000;	//max sensor distance in cm
	iMinSensorCm	: INT := 0;
	
	// threshold
	rLowThreshPct	: REAL;
	rHighThreshPct	: REAL;
	
END_VAR
VAR_OUTPUT
	xPumpActivate	: BOOL;
	
    eConfigError 	: E_TankConfigError;
	eTankState 		: E_TankState;
	
	rLevelPct		: REAL;
END_VAR
VAR
	rLevelCm		: REAL;	// measured from top
	
	rtStart			: R_TRIG;
	rtReset			: R_TRIG;
END_VAR

----------------


eTankState := E_TankState.eInitializing;

rtStart(CLK := (xStart AND NOT xStop));
rtReset(CLK := xReset);

CASE eTankState OF
	// VALIDATION
	E_TankState.eInitializing:
		xPumpActivate := FALSE;
		// Check low threshold
		IF (rLowThreshPct < 0.0) OR (rLowThreshPct > 1.0) THEN
			eConfigError := E_TankConfigError.eLowThresholdOutOfRange;
		
		// Check high threshold
		ELSIF (rHighThreshPct < 0.0) OR (rHighThreshPct > 1.0) THEN
			eConfigError := E_TankConfigError.eHighThresholdOutOfRange;
		
		// Check threshold order
		ELSIF rLowThreshPct >= rHighThreshPct THEN
			eConfigError := E_TankConfigError.eInvalidThresholdOrder;
		
		// Check tank depth
		ELSIF iTankDepthCm <= 0 THEN
			eConfigError := E_TankConfigError.eInvalidTankDepth;
		
		ELSIF iMaxRaw <= iMinRaw THEN
			eConfigError := E_TankConfigError.eInvalidRawRange;
		
		ELSIF iMaxSensorCm <= iMinSensorCm THEN
			eConfigError := E_TankConfigError.eInvalidSensorRange;
		
		END_IF
		
		IF (eConfigError = E_TankConfigError.eNoError) THEN
			eTankState := E_TankState.eReady;
		ELSE
			eTankState := E_TankState.eFault;	
		END_IF
		
	// READY
	E_TankState.eReady:
		xPumpActivate := FALSE;
		
		IF rtStart.Q THEN
			eTankState := E_TankState.eRunning;
		END_IF
	
	// RUNNING
	E_TankState.eRunning:
		IF xStop THEN
			eTankState := E_TankState.eReady;
		
		ELSIF (iLevelRaw < iMinRaw) OR (iLevelRaw > iMaxRaw) THEN
			eTankState := E_TankState.eFault;
		
		ELSE
			rLevelCm := 
				INT_TO_REAL(iMaxSensorCm - iMinSensorCm) / INT_TO_REAL(iMaxRaw - iMinRaw) * 
				INT_TO_REAL(iLevelRaw - iMinRaw) + INT_TO_REAL(iMinSensorCm);
			rLevelPct := (INT_TO_REAL(iTankDepthCm) - rLevelCm) / INT_TO_REAL(iTankDepthCm);
		
			IF rLevelPct < rLowThreshPct THEN
				xPumpActivate := TRUE;
			ELSIF rLevelPct > rHighThreshPct THEN
				xPumpActivate := FALSE;
			END_IF
		END_IF
	
	// FAULT
	E_TankState.eFault:
		xPumpActivate := FALSE;
		
		IF rtReset.Q THEN
			eConfigError := E_TankConfigError.eNoError;
		END_IF
		
END_CASE
