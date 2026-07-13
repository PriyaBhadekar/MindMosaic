package com.dement.utils;

import org.springframework.stereotype.Component;

@Component
public class GeofenceUtils {

    private static final double EARTH_RADIUS_METERS = 6371000.0;

    /**
     * Calculates the distance between two coordinates using the Haversine formula.
     * @return distance in meters
     */
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_METERS * c;
    }

    /**
     * Check if a point is outside the safe zone
     */
    public boolean isOutsideZone(double centerLat, double centerLon, double radius,
                                 double pointLat, double pointLon) {
        double distance = calculateDistance(centerLat, centerLon, pointLat, pointLon);
        return distance > radius;
    }
}