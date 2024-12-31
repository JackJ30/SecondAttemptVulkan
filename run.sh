#! /bin/bash
cmake -B build && cmake --build build --parallel 8 && (cd build && ./VulkanAttemptTwo)
