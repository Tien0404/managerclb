import { ref } from 'vue';

export function useNotification() {
  const showNotification = ref(false);
  const notificationType = ref('success');
  const notificationMessage = ref('');
  const notificationDuration = ref(5000); // Default duration: 5 seconds

  // Show a success notification
  const showSuccess = (message, duration = 5000) => {
    notificationType.value = 'success';
    notificationMessage.value = message;
    notificationDuration.value = duration;
    showNotification.value = true;
  };

  // Show an error notification
  const showError = (message, duration = 5000) => {
    notificationType.value = 'error';
    notificationMessage.value = message;
    notificationDuration.value = duration;
    showNotification.value = true;
  };

  // Show a warning notification
  const showWarning = (message, duration = 5000) => {
    notificationType.value = 'warning';
    notificationMessage.value = message;
    notificationDuration.value = duration;
    showNotification.value = true;
  };

  // Show an info notification
  const showInfo = (message, duration = 5000) => {
    notificationType.value = 'info';
    notificationMessage.value = message;
    notificationDuration.value = duration;
    showNotification.value = true;
  };

  // Hide the notification
  const hideNotification = () => {
    showNotification.value = false;
  };

  // Predefined success messages for common actions
  const showCreateSuccess = (itemName) => {
    showSuccess(`Đã tạo ${itemName} thành công!`);
  };

  const showUpdateSuccess = (itemName) => {
    showSuccess(`Đã cập nhật ${itemName} thành công!`);
  };

  const showDeleteSuccess = (itemName) => {
    showSuccess(`Đã xóa ${itemName} thành công!`);
  };

  // Predefined error messages for common actions
  const showCreateError = (itemName) => {
    showError(`Không thể tạo ${itemName}. Vui lòng thử lại.`);
  };

  const showUpdateError = (itemName) => {
    showError(`Không thể cập nhật ${itemName}. Vui lòng thử lại.`);
  };

  const showDeleteError = (itemName) => {
    showError(`Không thể xóa ${itemName}. Vui lòng thử lại.`);
  };

  return {
    showNotification,
    notificationType,
    notificationMessage,
    notificationDuration,
    showSuccess,
    showError,
    showWarning,
    showInfo,
    hideNotification,
    showCreateSuccess,
    showUpdateSuccess,
    showDeleteSuccess,
    showCreateError,
    showUpdateError,
    showDeleteError
  };
} 