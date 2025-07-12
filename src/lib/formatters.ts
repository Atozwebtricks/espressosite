// Data formatting utilities for espresso machine specifications

export function formatHeatupTime(seconds: number | null): string {
  if (!seconds || seconds === 0) return 'Unknown';
  
  if (seconds < 60) {
    return `${seconds}s`;
  } else {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    if (remainingSeconds === 0) {
      return `${minutes}m`;
    } else {
      return `${minutes}m ${remainingSeconds}s`;
    }
  }
}

export function formatWarranty(warranty: string | number | null): string {
  if (!warranty) return 'No warranty info';
  
  // If it's a number (warranty_years), format it
  if (typeof warranty === 'number') {
    if (warranty === 1) return '1-year limited';
    return `${warranty}-year limited`;
  }
  
  // If it's a string, return as-is (the original warranty text)
  return warranty;
}

export function formatBuiltInGrinder(grinder: string | null): string {
  switch (grinder) {
    case 'built-in':
      return 'Yes (built-in)';
    case 'external':
      return 'Yes (external)';
    case 'none':
    case null:
      return 'No';
    default:
      return grinder || 'Unknown';
  }
}

export function formatBoilerType(boilerType: string | null): string {
  switch (boilerType) {
    case 'Single boiler':
      return 'Single Boiler';
    case 'Dual boiler':
      return 'Dual Boiler';
    case 'Heat-exchange':
      return 'Heat Exchange';
    // Legacy values for backward compatibility
    case 'single':
      return 'Single Boiler';
    case 'dual':
      return 'Dual Boiler';
    case 'heat_exchanger':
      return 'Heat Exchange';
    case 'thermojet':
      return 'ThermoJet';
    default:
      return boilerType || 'Unknown';
  }
}

export function formatHeatingSystem(heatingSystem: string | null): string {
  switch (heatingSystem) {
    case 'Classic tank':
      return 'Classic Tank';
    case 'Thermoblock':
      return 'Thermoblock';
    case 'Thermocoil':
      return 'Thermocoil';
    case 'Thermojet':
      return 'ThermoJet';
    case 'Quick Heat boiler':
      return 'Quick Heat Boiler';
    default:
      return heatingSystem || 'Unknown';
  }
}

export function formatNumberOfBoilers(count: number | null): string {
  if (!count) return 'Unknown';
  if (count === 1) return '1 boiler';
  return `${count} boilers`;
}

export function formatPreInfusion(preInfusion: boolean | string | null): string {
  // Handle both new boolean format and legacy text format
  if (typeof preInfusion === 'boolean') {
    return preInfusion ? 'Yes' : 'No';
  }
  
  // Legacy format handling
  switch (preInfusion) {
    case 'none':
      return 'No';
    case 'mechanical':
      return 'Yes (Mechanical)';
    case 'programmable':
      return 'Yes (Programmable)';
    default:
      return preInfusion ? 'Yes' : 'No';
  }
}

export function formatWaterTank(liters: number | null): string {
  if (!liters || liters === 0) return 'Unknown';
  return `${liters}L`;
}

export function formatDimensions(dimensions: string | null): string {
  return dimensions || 'Unknown';
}

export function formatWeight(lbs: number | null): string {
  if (!lbs || lbs === 0) return 'Unknown';
  return `${lbs} lbs`;
}

export function formatPower(watts: number | null): string {
  if (!watts || watts === 0) return 'Unknown';
  return `${watts}W`;
}

export function formatPrice(price: number | null): string {
  if (!price || price === 0) return 'N/A';
  return `$${price.toLocaleString()}`;
}

export function formatPortafilter(mm: number | null): string {
  if (!mm || mm === 0) return 'Unknown';
  return `${mm}mm`;
}

export function formatYesNo(value: boolean | null): string {
  if (value === null) return 'Unknown';
  return value ? 'Yes' : 'No';
}

// Machine type formatting
export function formatMachineType(type: string | null): string {
  switch (type) {
    case 'Semi-automatic':
    case 'Semi-Automatic':
      return 'Semi-Automatic';
    case 'Super-automatic':
    case 'Super-Automatic':
      return 'Super-Automatic';
    case 'Automatic':
      return 'Automatic';
    case 'Manual':
      return 'Manual';
    default:
      return type || 'Unknown';
  }
}

// Steam wand type formatting
export function formatSteamWand(type: string | null): string {
  switch (type) {
    case 'manual':
      return 'Manual';
    case 'auto-frother':
      return 'Auto Frother';
    case 'cool-touch':
      return 'Cool Touch';
    default:
      return type || 'Manual';
  }
} 