function planarMarkers = markersToPlanarCoordinates(Markers, BaseMarker, PlaneSpan)
    
planarMarkers = (Markers - BaseMarker);
planarMarkers = tensorprod(PlaneSpan, planarMarkers, 1, 2);
planarMarkers = permute(planarMarkers, [2, 1, 3]);

end