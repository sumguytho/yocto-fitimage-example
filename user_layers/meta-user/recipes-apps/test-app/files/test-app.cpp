#include <iterator>
#include <utility>
#include <string>
#include <type_traits>

#include <cstdio>

struct my_sequence : std::integer_sequence<int, 1, 2, 3, 4, 5> { };

template <template <typename int_t, int_t... ints> typename int_seq_t, typename int_t, int_t... ints>
std::string to_string(int_seq_t<int_t, ints...> seq) {
    const static int_t ints_arr[] = { ints... };
    std::string result;
    auto iter = std::cbegin(ints_arr);

    if (std::size(ints_arr) >= 1) {
        result += std::to_string(*iter);
        ++iter;
    }
    for (; iter != std::cend(ints_arr); ++iter) {
        result += ' ' + std::to_string(*iter);
    }
    return result;
}

int main() {
    std::printf("test-app: %s.\n", to_string(my_sequence{}).c_str());
}
