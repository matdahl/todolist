import QtQuick 2.7
import Ubuntu.Components 1.3

ListModel{
    id: root

    // function to sort the model entries by priority
    function sort(){
        // go for each position except for the last
        for (var i=0; i<count-1; i++){
            var optVal = get(i).priority
            var optIndex = i
            for (var j=i+1;j<count; j++){
                var newVal = get(j).priority
                if (newVal>optVal) optIndex = j
            }
            move(optIndex,i,1)
        }
    }
}
