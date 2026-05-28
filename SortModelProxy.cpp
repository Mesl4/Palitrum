#include "SortProxyModel.h"

SortProxyModel::SortProxyModel(QObject *parent) : QSortFilterProxyModel(parent) {
    setDynamicSortFilter(true);
}

bool SortProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const {
    QVariant leftData = sourceModel()->data(left, sortRole());
    QVariant rightData = sourceModel()->data(right, sortRole());

    if (sortRole() == ModifiedDateRole) {
        return leftData.toString() < rightData.toString();
    }
    return leftData.toString().toLower() < rightData.toString().toLower();
}
