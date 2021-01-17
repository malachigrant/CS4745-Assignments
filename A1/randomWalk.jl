using Random

function randomWalk(dimensions, seed = nothing)
  if (seed != nothing)
    Random.seed!(seed);
  end
  A = fill('.', (dimensions, dimensions));
  point = [1;1];
  char = 'A';
  setPoint(A, point, char);
  for i = 1:25
    possiblePoints = getPossibleCoordinates(A, point);
    if (isempty(possiblePoints))
      break;
    end
    selectedPoint = possiblePoints[rand(1:size(possiblePoints)[1])];
    point = selectedPoint;
    char += 1;
    setPoint(A, point, char);
  end
  printArray(A);
end

function setPoint(arr, point, char)
  arr[point[1], point[2]] = char;
end

function getPossibleCoordinates(arr, point)
  dimensions = size(arr);
  rightPoint = [point[1];mod(point[2]+1, 1:dimensions[2])];
  downPoint = [mod(point[1]+1, 1:dimensions[1]);point[2]];
  leftPoint = [point[1];mod(point[2]-1, 1:dimensions[2])];
  upPoint = [mod(point[1]-1, 1:dimensions[1]);point[2]];

  points = [rightPoint, downPoint, leftPoint, upPoint];
  points = filter((x) -> arr[x[1], x[2]] == '.', points);
  return points;
end

function printArray(arr)
  for row in eachrow(arr)
    for col in eachindex(row)
      print("$(row[col]) ");
    end
    println();
  end
end