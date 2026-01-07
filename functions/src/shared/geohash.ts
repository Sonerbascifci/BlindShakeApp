import * as geofire from "geofire-common";

/**
 * Geohash utilities for location-based matching
 */

export interface GeoPoint {
  latitude: number;
  longitude: number;
}

export interface GeoHashRange {
  startValue: string;
  endValue: string;
}

/**
 * Calculate geohash for a location
 */
export function getGeoHash(location: GeoPoint, precision = 7) {
  return geofire.geohashForLocation([location.latitude, location.longitude], precision);
}

/**
 * Calculate distance between two locations in kilometers
 */
export function distanceBetween(location1: GeoPoint, location2: GeoPoint): number {
  return geofire.distanceBetween(
    [location1.latitude, location1.longitude],
    [location2.latitude, location2.longitude]
  );
}

/**
 * Get geohash ranges for proximity queries
 * @param center Center location
 * @param radiusKm Radius in kilometers (max 1000 for BlindShake)
 * @returns Array of geohash ranges for querying
 */
export function getGeoHashRanges(center: GeoPoint, radiusKm: number): GeoHashRange[] {
  // Ensure radius doesn't exceed 1000km limit
  const radius = Math.min(radiusKm, 1000);

  const bounds = geofire.geohashQueryBounds([center.latitude, center.longitude], radius * 1000); // Convert to meters

  return bounds.map(bound => ({
    startValue: bound[0],
    endValue: bound[1],
  }));
}

/**
 * Get appropriate geohash precision for radius
 * Smaller radius = higher precision = more accurate but smaller coverage
 */
export function getGeoHashPrecision(radiusKm: number): number {
  if (radiusKm <= 1) return 9;     // ~4.77m x 4.77m
  if (radiusKm <= 5) return 8;     // ~38.2m x 19.1m
  if (radiusKm <= 20) return 7;    // ~153m x 153m
  if (radiusKm <= 80) return 6;    // ~1.22km x 0.61km
  if (radiusKm <= 300) return 5;   // ~4.89km x 4.89km
  if (radiusKm <= 1000) return 4;  // ~39.1km x 19.5km
  return 3;                        // ~156km x 156km
}

/**
 * Validate if location is within acceptable bounds
 */
export function isValidLocation(location: GeoPoint): boolean {
  return (
    location.latitude >= -90 &&
    location.latitude <= 90 &&
    location.longitude >= -180 &&
    location.longitude <= 180
  );
}

/**
 * Generate multiple geohash precisions for layered matching
 * This allows for both nearby and wider area matching
 */
export function generateGeohashLayers(location: GeoPoint): { [precision: number]: string } {
  const layers: { [precision: number]: string } = {};

  // Generate geohashes at different precisions for multi-layer matching
  for (let precision = 4; precision <= 8; precision++) {
    layers[precision] = getGeoHash(location, precision);
  }

  return layers;
}