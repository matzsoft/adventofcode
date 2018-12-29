module ManhattanBar(size) {
    cube( [ 2 * size + 1, 1, 1 ], true );
}

module ManhattanCircle(size) {
    ManhattanBar(size);
    if ( size > 0 ) {
        for( i = [1:size] ) {
            translate([0,i,0]) ManhattanBar( size - i );
            translate([0,-i,0]) ManhattanBar( size - i );
        }
    }
}

module ManhattanSphere(size) {
    ManhattanCircle(size);
    if ( size > 0 ) {
        for( i = [1:size] ) {
            translate([0,0,i]) ManhattanCircle( size - i );
            translate([0,0,-i]) ManhattanCircle( size - i );
        }
    }
}

module octahedron(size) {
    polyhedron(
        points = [ [0,0,size], [0,size,0], [size,0,0], [0,-size,0], [-size,0,0], [0,0,-size] ],
        faces  = [ [0,1,2], [0,2,3], [0,3,4], [0,4,1], [5,3,2], [5,2,1], [5,1,4], [5,4,3] ]
    );
}

/*
intersection() {
    offset = 3;

    ManhattanSphere(7);
    translate( [1,2,3] ) ManhattanSphere(5);
}
*/

intersection() {
    offset = 2;

    octahedron(7);
    translate( [1,2,3] ) octahedron(5);
}
