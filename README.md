
# Tank Level Control – PLC Structured Text

A small tank level control project developed in IEC 61131-3 Structured Text (ST).

The purpose of this project is to practise fundamental PLC programming concepts, including configuration validation, analogue sensor scaling, hysteresis control, state machines, and fault handling.

## Project Goals

- Learn IEC 61131-3 Structured Text.
- Convert a raw analogue sensor value into a meaningful tank level.
- Control a pump using two configurable thresholds.
- Implement a simple PLC state machine.
- Detect invalid sensor readings.
- Handle faults and require deliberate operator reset.

## Features

- Configuration validation during initialization.
- Analogue sensor scaling from raw input to distance.
- Tank level calculation as a percentage.
- Two-threshold hysteresis control.
- Rising-edge detection for Start and Reset.
- Four operating states.
- Latched fault handling.
- Pump output disabled in Ready and Fault states.

## Operating States

| State | Description |
|---|---|
| `eInitializing` | Validates configuration parameters. |
| `eReady` | Configuration is valid; waits for Start. |
| `eRunning` | Calculates tank level and controls the pump. |
| `eFault` | Disables the pump and waits for operator Reset. |

### State Sequence

1. The controller starts in `eInitializing`.
2. Configuration parameters are checked.
3. If configuration is valid, the controller enters `eReady`.
4. A rising edge on Start transitions the controller to `eRunning`.
5. Stop returns the controller to `eReady`.
6. An invalid sensor reading causes a transition to `eFault`.
7. The pump is disabled while in Fault.
8. Reset is accepted only when the sensor reading is valid.
9. The controller returns to `eInitializing` and validates its configuration again.

## Tank Level Calculation

The raw analogue sensor reading is converted into a distance measurement using linear scaling:

```iecst
rLevelCm :=
    INT_TO_REAL(iMaxSensorCm - iMinSensorCm) /
    INT_TO_REAL(iMaxRaw - iMinRaw) *
    INT_TO_REAL(iLevelRaw - iMinRaw) +
    INT_TO_REAL(iMinSensorCm);
```

The tank level percentage is calculated as:

```iecst
rLevelPct :=
    (INT_TO_REAL(iTankDepthCm) - rLevelCm) /
    INT_TO_REAL(iTankDepthCm);
```

This calculation assumes the sensor measures distance downward from the top of the tank: a smaller distance means a higher liquid level.

## Pump Control

The pump uses two thresholds to implement hysteresis.

- If the level falls below the low threshold, the pump activates.
- If the level rises above the high threshold, the pump deactivates.
- Between the two thresholds, the previous pump command is maintained.

This prevents rapid switching when the tank level is close to a single threshold.

## Configuration Parameters

| Parameter | Description |
|---|---|
| `rLowThreshPct` | Low-level activation threshold (0.0–1.0). |
| `rHighThreshPct` | High-level deactivation threshold (0.0–1.0). |
| `iTankDepthCm` | Configured tank depth in centimetres. |
| `iMinRaw` | Minimum calibrated raw sensor value. |
| `iMaxRaw` | Maximum calibrated raw sensor value. |
| `iMinSensorCm` | Distance corresponding to minimum raw value. |
| `iMaxSensorCm` | Distance corresponding to maximum raw value. |
| `iLevelRaw` | Current raw analogue sensor reading. |

Configuration validation checks:

- Thresholds are within the range 0.0–1.0.
- The low threshold is sufficiently below the high threshold.
- Tank depth is positive.
- Maximum raw value is greater than minimum raw value.
- Maximum sensor distance is greater than minimum sensor distance.

## Fault Handling

The controller enters Fault when the sensor reading is outside its configured raw range.

While in Fault:

- The pump command is disabled.
- The controller does not automatically resume operation when the sensor reading recovers.
- An operator must request Reset.
- Reset is accepted only when the sensor reading is back within range.
- Configuration is validated again before operation can resume.

This approach makes faults visible and prevents unexpected automatic recovery.

## Suggested Test Scenarios

| Test | Expected result |
|---|---|
| Valid configuration at startup | Transition to Ready |
| Invalid low threshold | Configuration fault |
| Invalid high threshold | Configuration fault |
| Low threshold greater than or too close to high threshold | Configuration fault |
| Invalid tank depth | Configuration fault |
| Invalid raw calibration range | Configuration fault |
| Press Start in Ready | Transition to Running |
| Level below low threshold | Pump activates |
| Level above high threshold | Pump deactivates |
| Level between thresholds | Previous pump command is maintained |
| Press Stop in Running | Pump deactivates; transition to Ready |
| Sensor reading outside calibrated range | Pump deactivates; transition to Fault |
| Sensor recovers without Reset | Controller remains in Fault |
| Reset while sensor is invalid | Reset is rejected |
| Reset while sensor is valid | Reinitialization begins |

## Project Limitations

This is an educational project, not a production-ready or safety-rated control system.

The following assumptions must be confirmed before using the logic with real equipment:

- The sensor measures distance downward from the top of the tank.
- The raw sensor value increases as measured distance increases.
- The pump operation is compatible with the chosen level-control behavior.
- The analogue input is correctly configured and scaled for the selected PLC hardware.

Additional protections, such as sensor electrical diagnostics, pump feedback, independent high-level protection, and safety interlocks, are outside the current project scope.

## Possible Future Improvements

1. Separate configuration errors from sensor errors.
2. Add a dedicated sensor error enumeration.
3. Add operator-readable fault diagnostics.
4. Add pump feedback monitoring.
5. Add a manual operating mode.
6. Add simulation and automated test cases.

## Learning Focus

The main objective is to build a solid foundation in practical PLC programming:

- Structured Text syntax.
- Enumerations and state machines.
- Function blocks and rising-edge detection.
- Analogue signal scaling.
- Hysteresis control.
- Configuration validation.
- Fault detection and recovery.

The project should remain simple enough to understand, test, and explain during a PLC job interview.
