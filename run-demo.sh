# © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

swift build -c release;
.build/release/tddbuddy \
  --input Tests/CoreE2ETests/inputs/adder.swift.txt \
  --output generated/adder.swift \
  --iterations 5
