#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include "cmocka.h"

static void test_1(void **state)
{
    assert_false(0);
}

static void test_2(void **state)
{
    assert_false(0);
}

static void test_3(void **state)
{
    assert_false(1);
}

static void test_4(void **state)
{
    assert_false(0);
}

int main(void)
{

    const struct CMUnitTest tests[] = {
        cmocka_unit_test(test_1),
        cmocka_unit_test(test_2),
        cmocka_unit_test(test_3),
        cmocka_unit_test(test_4)
    };

    return cmocka_run_group_tests(tests, NULL, NULL);

}
