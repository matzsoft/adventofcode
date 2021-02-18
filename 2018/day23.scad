module ManhattanSphere(size) {
    octahedron(size);
}

module octahedron(size) {
    polyhedron(
        points = [ [0,0,size], [0,size,0], [size,0,0], [0,-size,0], [-size,0,0], [0,0,-size] ],
        faces  = [ [0,1,2], [0,2,3], [0,3,4], [0,4,1], [5,3,2], [5,2,1], [5,1,4], [5,4,3] ]
    );
}

intersection() {
    ManhattanSphere(7);
    translate( [1,2,3] ) ManhattanSphere(5);
}
