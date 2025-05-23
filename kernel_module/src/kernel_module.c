#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/ioport.h>
#include <asm/errno.h>
#include <asm/io.h>
#include <linux/kobject.h> 
#include <linux/sysfs.h>

MODULE_INFO(intree, "Y");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Natalia Slepowronska");
MODULE_DESCRIPTION("Simple kernel module for SYKOM lecture");
MODULE_VERSION("0.01");

#define SYKT_GPIO_BASE_ADDR     (0x00100000)
#define SYKT_GPIO_SIZE          (0x8000)
#define SYKT_EXIT               (0x3333)
#define SYKT_EXIT_CODE          (0x7F)

#define SYKT_GPIO_ADDR_SPACE (SYKT_GPIO_BASE_ADDR)

#define IN_ADDR                 (SYKT_GPIO_ADDR_SPACE + 0xCC0)
#define CTRL_ADDR               (SYKT_GPIO_ADDR_SPACE + 0xCD8)
#define STATE_ADDR              (SYKT_GPIO_ADDR_SPACE + 0xCC8)
#define RESULT_ADDR             (SYKT_GPIO_ADDR_SPACE + 0xCD0)

// struct kobject - model jadra
struct kobject *sykt;

// mapowanie pamieci
void __iomem *baseptr;
void __iomem *in;
void __iomem *ctrl;
void __iomem *result;
void __iomem *state;

// funkcje odczytu i zapisu
static ssize_t reg_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf, unsigned long *reg){
    unsigned long val = readl(reg);
    return sprintf(buf, "%lx\n", val);
}

static ssize_t reg_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t val, unsigned long *reg){
    unsigned long x;
    if (sscanf(buf, "%lx", &x) <= 0) {
        return 0;
    }
    writel(x, reg);
    return val;
}

// funkcje odczytu i zapisu dla zdefiniowanych adresow
static ssize_t dsslna_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return reg_show(kobj, attr, buf, in);
}
static ssize_t dsslna_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t val){
    return reg_store(kobj, attr, buf, val, in);
}
static struct kobj_attribute dsslna_attr = __ATTR_RW(dsslna);

static ssize_t dtslna_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return reg_show(kobj, attr, buf, ctrl);
}
static ssize_t dtslna_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t val){
    return reg_store(kobj, attr, buf, val, ctrl);
}
static struct kobj_attribute dtslna_attr = __ATTR_RW(dtslna);

static ssize_t dcslna_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return reg_show(kobj, attr, buf, state);
}
static struct kobj_attribute dcslna_attr = __ATTR_RO(dcslna);

static ssize_t drslna_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return reg_show(kobj, attr, buf, result);
}
static struct kobj_attribute drslna_attr = __ATTR_RO(drslna);

// tworzenie atrybutow w przestrzeni /sys
static struct attribute *sykt_attrs[] = {
    &dsslna_attr.attr,
    &dtslna_attr.attr,
    &dcslna_attr.attr,
    &drslna_attr.attr,
    NULL,
};

// grupowanie atrybutow
static struct attribute_group sykt_attr_group = {
    .attrs = sykt_attrs,
};

int my_init_module(void){

    printk(KERN_INFO "Init my module.\n");
    // mapowanie pamieci GPIO na przestrzen jadra
    baseptr=ioremap(SYKT_GPIO_BASE_ADDR, SYKT_GPIO_SIZE);
    in = ioremap(IN_ADDR, SYKT_GPIO_SIZE);
    ctrl = ioremap(CTRL_ADDR, SYKT_GPIO_SIZE);
    state = ioremap(STATE_ADDR, SYKT_GPIO_SIZE);
    result = ioremap(RESULT_ADDR, SYKT_GPIO_SIZE);

    if (!baseptr || !in || !ctrl || !state || !result) {
        pr_err("SYKT: Failed to map I/O memory\n");
        return -ENOMEM;
    }

    sykt = kobject_create_and_add("sykt", kernel_kobj);
    if (!sykt) {
        pr_err("SYKT: Failed to create kobject\n");
        return -ENOMEM;
    }

    if (sysfs_create_group(sykt, &sykt_attr_group)) {
        pr_err("SYKT: Failed to create sysfs group\n");
        kobject_put(sykt);
        return -ENOMEM;
    }

    return 0;
}

void my_cleanup_module(void){
    printk(KERN_INFO "Cleanup my module.\n");
    writel(SYKT_EXIT | ((SYKT_EXIT_CODE)<<16), baseptr);
    iounmap(baseptr);
    iounmap(in);
    iounmap(ctrl);
    iounmap(state);
    iounmap(result);
    kobject_put(sykt);
}

module_init(my_init_module)
module_exit(my_cleanup_module)
